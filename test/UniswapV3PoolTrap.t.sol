// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {UniswapV3PoolTrap} from "../src/UniswapV3PoolTrap.sol";

contract UniswapV3PoolTrapTest is Test {
    uint8 numBlocks = 5;
    uint256 blockNumber;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"));
        blockNumber = block.number;
    }

    function test_uniswapV3PoolTrap() public {
      UniswapV3PoolTrap.CollectOutput[] memory dataPoints = new UniswapV3PoolTrap.CollectOutput[](numBlocks);

      // Collect data points starting from the current block minus 'numBlocks'
      for (uint8 i = 0; i < numBlocks; i++) {
        dataPoints[i] = new UniswapV3PoolTrap().collect();

        // Advance to the next block
        vm.rollFork(blockNumber - numBlocks + i);
      }

      bool isValid = new UniswapV3PoolTrap().isValid(dataPoints);
      
      assertTrue(isValid);
    }
}
