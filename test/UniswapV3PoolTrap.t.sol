// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {UniswapV3PoolTrap} from "../src/UniswapV3PoolTrap.sol";

contract UniswapV3PoolTrapTest is Test {
    uint8 numBlocks = 3;
    uint256 blockNumber;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"));
        blockNumber = block.number;
    }

    function test_uniswapV3PoolTrap() public {
      UniswapV3PoolTrap.CollectOutput[] memory dataPoints = new UniswapV3PoolTrap.CollectOutput[](numBlocks);

      // Collect data points starting from the current block minus 'numBlocks'
      for (uint8 i = 0; i < numBlocks; i++) {
        dataPoints[i] = _deployTrap().collect();
        vm.rollFork(blockNumber - numBlocks + i);
      }

      _deployTrap().isValid(dataPoints);
    }

    function _deployTrap() public returns (UniswapV3PoolTrap) {
      address ethUsdcPool = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;
      return new UniswapV3PoolTrap(ethUsdcPool);
    }
}
