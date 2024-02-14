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

    address public constant ethUsdcPool = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;
    IUniswapV3PoolState public pool;

    constructor() {
        // Initialization logic is executed once per block. Any state changes here are persisted
        // for the duration of the 'collect' function call.
        pool = IUniswapV3PoolState(ethUsdcPool);
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
