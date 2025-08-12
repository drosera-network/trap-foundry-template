// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {Trap, EventFilter, EventLog, EventFilterLib} from "./Trap.sol";


enum AllowanceType {
    ERC20,
    Permit2
}

struct AllowanceData {
    address target;
    address owner;
    address spender;
    address token;
    uint256 value;
    AllowanceType allowanceType;
}

struct Execution {
    address target;
    uint256 value;
    bytes callData;
}

struct CollectOutput {
    AllowanceData[] allowances;
}

contract RevokeAllAllowanceTrap is Trap {
    using EventFilterLib for EventFilter;

    address private user_address;
    address private permit2;
    
    // @notice Using constructor to initialize the trap with the user address for testing. 
    // In production, user address will need to be set as a constant. 
    constructor(address _userAddress, address _permit2) {
        user_address = _userAddress;
        permit2 = _permit2;
    }
    
    function collect() external view override returns (bytes memory) {
        EventLog[] memory logs = getEventLogs();
        EventFilter[] memory filters = eventLogFilters();

        AllowanceData[] memory allowances = new AllowanceData[](logs.length);
        uint256 allowanceCount = 0;

        for (uint256 i = 0; i < logs.length; i++) {
            EventLog memory log = logs[i];

            // Check if the log matches the filter for Approval events
            if (filters[0].matches_signature(log)) {
                (address owner, address spender, uint256 value) = parseApprovalEvent(log);
                // Only record allowances where the owner is the user address and value is greater than zero
                if (owner == user_address && value > 0) {
                     allowances[allowanceCount] = AllowanceData({
                        target: log.emitter, // The contract that emitted the event is the token address
                        owner: owner,
                        spender: spender,
                        token: log.emitter,
                        value: value,
                        allowanceType: AllowanceType.ERC20
                    });
                    // Increment the allowance count
                    allowanceCount++;
                } 
            }

            if (filters[1].matches(log)) {
                (address owner, address token, address spender, uint160 amount, ) = parsePermitApprovalEvent(log);
                // Only record allowances where the owner is the user address and value is greater than zero
                if (owner == user_address && amount > 0) {
                     allowances[allowanceCount] = AllowanceData({
                        target: log.emitter, // The contract that emitted the event is the Permit2 address
                        owner: owner,
                        spender: spender,
                        token: token, // The contract that emitted the event is the token address
                        value: amount,
                        allowanceType: AllowanceType.Permit2
                    });
                    // Increment the allowance count
                    allowanceCount++;
                } 
            }

            if (filters[2].matches(log)) {
                (address owner, address token, address spender, uint160 amount, , ) = parsePermitEvent(log);
                // Only record allowances where the owner is the user address and value is greater than zero
                if (owner == user_address && amount > 0) {
                     allowances[allowanceCount] = AllowanceData({
                        target: log.emitter, 
                        owner: owner,
                        spender: spender,
                        token: token, // The contract that emitted the event is the token address
                        value: amount,
                        allowanceType: AllowanceType.Permit2
                    });
                    // Increment the allowance count
                    allowanceCount++;
                } 
            }
        }

        // Resize the allowances array to the actual number of allowances found
        AllowanceData[] memory resizedAllowances = new AllowanceData[](allowanceCount);
        for (uint256 j = 0; j < allowanceCount; j++) {
            resizedAllowances[j] = allowances[j];
        }

        CollectOutput memory output = CollectOutput({
            allowances: resizedAllowances
        });

        return abi.encode(output);
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        // Grab the last collect output from the data array to allow time for the contract to use the allowance
        uint allowanceesLength = data.length;
        CollectOutput memory output = abi.decode(data[allowanceesLength - 1], (CollectOutput));

        Execution[] memory executions = new Execution[](allowanceesLength);
        
        for (uint256 i = 0; i < allowanceesLength; i++) {
            AllowanceData memory allowance = output.allowances[i];

            if (allowance.allowanceType == AllowanceType.ERC20) {
                // Create an execution to revoke the allowance for ERC20 tokens
                executions[i] = createRevokeAllowanceExecution(allowance.token, allowance.spender);
            } else if (allowance.allowanceType == AllowanceType.Permit2) {
                // Create an execution to revoke the allowance for Permit2 tokens
                executions[i] = createRevokeAllowanceExecutionForPermit2(allowance.target, allowance.token, allowance.spender);
            }
        }

        if (executions.length > 0) {
            // If there are allowances to revoke, return true and the executions
            return (true, abi.encode(executions));
        }

        return (false, "");
    }

    function eventLogFilters() public view override returns (EventFilter[] memory) {
        EventFilter[] memory filters = new EventFilter[](3);

        filters[0] = EventFilter({
            contractAddress: address(0), // Set to zero address to match any contract when using `matches_signature`
            // event Approval(address indexed owner, address indexed spender, uint256 value);
            signature: "Approval(address,address,uint256)"
        });

        filters[1] = EventFilter({
            contractAddress: permit2,
            // event Approval(
            //     address indexed owner, address indexed token, address indexed spender, uint160 amount, uint48 expiration
            // );
            signature: "Approval(address,address,address,uint160,uint48)"
        });

        filters[2] = EventFilter({
            contractAddress: permit2,
            // event Permit(
            //     address indexed owner,
            //     address indexed token,
            //     address indexed spender,
            //     uint160 amount,
            //     uint48 expiration,
            //     uint48 nonce
            // );
            signature: "Permit(address,address,address,uint160,uint48,uint48)"
        });

        return filters;
    }

    function parseApprovalEvent(
        EventLog memory log
    ) internal pure returns (address from, address to, uint256 amount) {
        require(log.topics.length == 3, "Invalid Transfer event log");
        from = address(uint160(uint256(log.topics[1])));
        to = address(uint160(uint256(log.topics[2])));
        amount = abi.decode(log.data, (uint256));
    }

    function parsePermitApprovalEvent(
        EventLog memory log
    ) internal pure returns (
        address owner,
        address token,
        address spender,
        uint160 amount,
        uint48 expiration
    ) {
        require(log.topics.length == 4, "Invalid Permit2 Approval event log");
        owner = address(uint160(uint256(log.topics[1])));
        token = address(uint160(uint256(log.topics[2])));
        spender = address(uint160(uint256(log.topics[3])));
        (amount, expiration) = abi.decode(log.data, (uint160, uint48));
    }

    function parsePermitEvent(
        EventLog memory log
    ) internal pure returns (
        address owner,
        address token,
        address spender,
        uint160 amount,
        uint48 expiration,
        uint48 nonce
    ) {
        require(log.topics.length == 4, "Invalid Permit2 event log");
        owner = address(uint160(uint256(log.topics[1])));
        token = address(uint160(uint256(log.topics[2])));
        spender = address(uint160(uint256(log.topics[3])));
        (amount, expiration, nonce) = abi.decode(log.data, (uint160, uint48, uint48));
    }

    function createRevokeAllowanceExecution(
        address token,
        address spender
    ) internal pure returns (Execution memory) {
        return Execution({
            target: token,
            value: 0,
            callData: abi.encodeWithSignature(
                "approve(address,uint256)",
                spender,
                0
            )
        });
    }

    function createRevokeAllowanceExecutionForPermit2(
        address target,
        address token,
        address spender
    ) internal pure returns (Execution memory) {
        return Execution({
            target: target,
            value: 0,
            callData: abi.encodeWithSignature(
                "approve(address,address,uint256,uint48)",
                token,
                spender,
                0,
                0
            )
        });
    }
}
