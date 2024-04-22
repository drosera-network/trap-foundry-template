// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

struct CollectOutput {
    uint256 isTriggered;
}

// NOTE: This Trap expects to be configured with a block sample size of 1
contract AlertTrap {
    uint256 private triggerAtBlockNumber = 0;

    constructor() {}

    function collect() external view returns (CollectOutput memory) {
        return
            CollectOutput({
                isTriggered: block.number != triggerAtBlockNumber ? 1 : 0
            });
    }

    function isValid(
        CollectOutput[] calldata dataPoints
    ) external pure returns (bool) {
        for (uint256 i = 0; i < dataPoints.length; i++) {
            if (dataPoints[i].isTriggered != 1) {
                return false;
            }
        }

        return true;
    }

    // NOTE: Set the block number to a specific block number in the future
    function setTriggerBlockNumber(uint256 _blockNumber) external {
        triggerAtBlockNumber = _blockNumber;
    }
}
