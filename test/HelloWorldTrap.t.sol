// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {Test} from "forge-std/Test.sol";
import {CollectOutput, HelloWorldTrap} from "../src/HelloWorldTrap.sol";

// forge test --contracts ./test/HelloWorld.t.sol -vvvv
contract HelloWorldTrapTest is Test {
    uint8 numBlocks = 10;
    uint256 blockNumber;
    uint256[] forkIds = new uint256[](numBlocks);

    function setUp() public {
        uint256 latestIndex = numBlocks - 1;
        uint256 latestForkId = vm.createSelectFork(
            "https://ethereum-hoodi-rpc.publicnode.com"
        );
        blockNumber = block.number;
        forkIds[latestIndex] = latestForkId;

        // [0] index is the most recent block (T0)
        // [numBlocks - 1] index is the oldest block (T9)
        // ---------------------------------------
        // [9]                               /
        // [8]                              /
        // [7]                             /
        // [6]          -------------------
        // [5]         /
        // [4]        /
        // [3]    ----
        // [2]   /
        // [1]  /
        // [0] [1] [2] [3] [4] [5] [6] [7] [8] [9]
        //                  <- Time (T)
        // ---------------------------------------

        for (uint8 i = 0; i < latestIndex; i++) {
            forkIds[i] = vm.createFork(
                "https://ethereum-hoodi-rpc.publicnode.com",
                blockNumber - i
            );
        }
    }

    function test_HelloWorldTrap() public {
        bytes[] memory dataPoints = new bytes[](numBlocks);

        // Collect data points starting from the current block minus 'numBlocks'
        for (uint8 i = 0; i < numBlocks; i++) {
            // Advance to an older block
            vm.selectFork(forkIds[i]);
            dataPoints[i] = new HelloWorldTrap().collect();
        }
        (bool shouldRespond, ) = new HelloWorldTrap().shouldRespond(dataPoints);
        assertTrue(!shouldRespond);
    }
}
