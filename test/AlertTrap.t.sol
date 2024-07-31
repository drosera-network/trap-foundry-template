// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {Test} from "forge-std/Test.sol";
import {CollectOutput, AlertTrap} from "../src/AlertTrap.sol";

// forge test --contracts ./test/AlertTrap.t.sol -vvvv
contract AlertTrapTest is Test {
    uint8 numBlocks = 1;
    uint256 blockNumber;
    uint256[] forkIds = new uint256[](numBlocks);

    function setUp() public {
        uint256 latestIndex = numBlocks - 1;
        uint256 latestForkId = vm.createSelectFork(vm.rpcUrl("mainnet"));
        blockNumber = block.number;
        forkIds[latestIndex] = latestForkId;
    }

    function test_AlertTrapNotTriggered() public {
        bytes[] memory dataPoints = new bytes[](numBlocks);

        // Collect data points starting from the current block
        dataPoints[0] = new AlertTrap().collect();
        (bool shouldRespond, ) = new AlertTrap().shouldRespond(dataPoints);

        assertTrue(!shouldRespond);
    }

    function test_AlertTrapTriggered() public {
        bytes[] memory dataPoints = new bytes[](numBlocks);

        AlertTrap trap = new AlertTrap();

        // FOR TESTING PURPOSES: Set the trigger block number to the next block for testing purposes
        trap.setTriggerBlockNumber(block.number);

        // Collect data points starting from the current block
        dataPoints[0] = trap.collect();
        (bool shouldRespond, ) = trap.shouldRespond(dataPoints);

        assertTrue(shouldRespond);
    }
}
