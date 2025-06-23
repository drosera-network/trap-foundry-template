// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {Test} from "forge-std/Test.sol";
import {CollectOutput, ResponseTrap} from "../src/ResponseTrap.sol";

// forge test --contracts ./test/ResponseTrap.t.sol -vvvv
contract ResponseTrapTest is Test {
    uint8 numBlocks = 1;
    uint256 blockNumber;
    uint256[] forkIds = new uint256[](numBlocks);

    function setUp() public {
        uint256 latestIndex = numBlocks - 1;
        uint256 latestForkId = vm.createSelectFork(
            "https://ethereum-hoodi-rpc.publicnode.com"
        );
        blockNumber = block.number;
        forkIds[latestIndex] = latestForkId;
    }

    function test_ResponseTrapNotTriggered() public {
        bytes[] memory dataPoints = new bytes[](numBlocks);

        // Collect data points starting from the current block
        dataPoints[0] = new ResponseTrap().collect();
        (bool shouldRespond, ) = new ResponseTrap().shouldRespond(dataPoints);

        assertTrue(!shouldRespond);
    }

    function test_ResponseTrapTriggered() public {
        bytes[] memory dataPoints = new bytes[](numBlocks);

        ResponseTrap trap = new ResponseTrap();

        // FOR TESTING PURPOSES: Set the trigger block number to the next block for testing purposes
        trap.setTriggerBlockNumber(block.number);

        // Collect data points starting from the current block
        dataPoints[0] = trap.collect();
        (bool shouldRespond, ) = trap.shouldRespond(dataPoints);

        assertTrue(shouldRespond);
    }
}
