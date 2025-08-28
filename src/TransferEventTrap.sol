// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {Trap, EventFilter, EventLog, EventFilterLib} from "drosera-contracts/Trap.sol";

struct CollectOutput {
    uint256 totalTransferAmount;
}

contract TransferEventTrap is Trap {
    using EventFilterLib for EventFilter;

    // @notice When using in production, token address will need to be set as a constant. 
    address private tokenAddress;
    
    // @notice Using constructor to initialize the trap with the token address for testing. 
    // In production, token address will need to be set as a constant. 
    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }
    
    function collect() external view override returns (bytes memory) {
        EventLog[] memory logs = getEventLogs();
        EventFilter[] memory filters = eventLogFilters();

        uint256 totalTransferAmount = 0;
        for (uint256 i = 0; i < logs.length; i++) {
            EventLog memory log = logs[i];

            // Check if the log matches the filter for Transfer events
            if (filters[0].matches(log)) {
                (,, uint256 amount) = parseTransferEvent(log);
                totalTransferAmount += amount;
            }
        }

        CollectOutput memory output = CollectOutput({
            totalTransferAmount: totalTransferAmount
        });

        return abi.encode(output);
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        CollectOutput memory output = abi.decode(data[0], (CollectOutput));

       if (output.totalTransferAmount > 100) {
            return (true, abi.encode("Transfer amount exceeds threshold"));
        }

        return (false, "");
    }

    function eventLogFilters() public view override returns (EventFilter[] memory) {
        EventFilter[] memory filters = new EventFilter[](1);

        filters[0] = EventFilter({
            contractAddress: tokenAddress,
            // The signature string of the Transfer event. This is used to generate the topic filter 
            signature: "Transfer(address,address,uint256)"
        });

        return filters;
    }

    function parseTransferEvent(
        EventLog memory log
    ) internal pure returns (address from, address to, uint256 amount) {
        require(log.topics.length == 3, "Invalid Transfer event log");
        from = address(uint160(uint256(log.topics[1])));
        to = address(uint160(uint256(log.topics[2])));
        amount = abi.decode(log.data, (uint256));
    }
}
