// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IUniswapV3PoolState {
  /// @notice The currently in range liquidity available to the pool
  /// @dev This value has no relationship to the total liquidity across all ticks
  function liquidity() external view returns (uint128);
}

contract UniswapV3PoolTrap {
    struct CollectOutput {
        // Define data collection points here

        uint128 liquidity;
    }

    uint8 public constant MIN_DATA_LEN = 2;
    IUniswapV3PoolState public pool;

    constructor(address poolAddress) {
        pool = IUniswapV3PoolState(poolAddress);
    }

    function collect() external view returns (CollectOutput memory) {
        // Data collection and monitoring logic goes here

        uint128 liquidity = pool.liquidity();
        return CollectOutput({liquidity: liquidity});
    }

    function isValid(CollectOutput[] calldata dataPoints) external pure returns (bool) {
        // Data validation logic goes here
        if (dataPoints.length < MIN_DATA_LEN) {
            return true;
        }
        // Eg: Check if the liquidity has decreased by more than 20% from the previous block
        if (dataPoints[1].liquidity < dataPoints[0].liquidity) {
            uint128 diff = dataPoints[0].liquidity - dataPoints[1].liquidity;
            if (diff > (dataPoints[0].liquidity / 5)) {
              return false;
            }
        } 
        return true;
    } 
}
