// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;


import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {TransferEventTrap} from "../src/TransferEventTrap.sol";
import {EventLog} from "drosera-contracts/Trap.sol";

// @notice This is a simple token contract to test the TransferEventTrap. 
contract Token {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function transfer(address to, uint256 amount) public {
        // Transfer logic
        emit Transfer(msg.sender, to, amount);
    }
}

// 
contract TransferEventTrapTest is Test {
    Token token;

    function setUp() public {
        token = new Token();
    }

    function testTransferEventShouldResponseTrue() public {
        vm.recordLogs();

        token.transfer(address(0x123), 100);
        token.transfer(address(0x123), 100);

        /////// Operator Operations

        // Retrieve recorded logs
        Vm.Log[] memory logs = vm.getRecordedLogs();
 
        // Deploy the TransferEventTrap with the token address
        TransferEventTrap transferTrap = new TransferEventTrap(address(token));

        // Set the event logs in the trap
        transferTrap.setEventLogs(mapLogsToEventLogs(logs));

        // Call the collect function to gather event data
        bytes memory collectData = transferTrap.collect();

        // Store the collected data into an array
        bytes[] memory collectedData = new bytes[](1);
        collectedData[0] = collectData;

        // Call shouldRespond to check if the trap should respond
        (bool respond, bytes memory data) = transferTrap.shouldRespond(collectedData);

        /////// End of operator operations

        assertTrue(respond, "Event detection should return true");
        assertEq(string(data), "Transfer amount exceeds threshold", "Response message should match expected");
    }

    // Neeeded to avoid pulling a dependency in the Trap contract
    function mapLogsToEventLogs(Vm.Log[] memory logs) internal pure returns (EventLog[] memory) {
        EventLog[] memory eventLogs = new EventLog[](logs.length);
        for (uint256 i = 0; i < logs.length; i++) {
            eventLogs[i] = EventLog({
                emitter: logs[i].emitter,
                topics: logs[i].topics,
                data: logs[i].data
            });
        }
        return eventLogs;
    }
}
