// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {ITrap} from "./interfaces/ITrap.sol";

struct CollectOutput {
    uint256 isTriggered;
}

// NOTE: This Trap expects to be configured with a block sample size of 1
contract AlertTrap is ITrap{
    uint256 private triggerAtBlockNumber = 0;

    constructor() {}

    function collect() external view returns (bytes memory) {
        return
            abi.encode(CollectOutput({
                isTriggered: block.number != triggerAtBlockNumber ? 1 : 0
            }));
    }

    function isValid(
        bytes[] calldata dataPoints
    ) external pure returns (bool, bytes memory) {
        for (uint256 i = 0; i < dataPoints.length; i++) {
            CollectOutput memory output = abi.decode(dataPoints[i], (CollectOutput));
            if (output.isTriggered != 1) {
                return (false, bytes(""));
            }
        }

        return (true, bytes(""));
    }

    // NOTE: Set the block number to a specific block number in the future
    function setTriggerBlockNumber(uint256 _blockNumber) external {
        triggerAtBlockNumber = _blockNumber;
    }
}
