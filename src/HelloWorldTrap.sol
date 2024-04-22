// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

struct CollectOutput {
    string text;
}

contract HelloWorldTrap {
    constructor() {}

    function collect() external view returns (CollectOutput memory) {
        return CollectOutput({text: "Hello World!"});
    }

    function isValid(
        CollectOutput[] calldata dataPoints
    ) external pure returns (bool) {
        for (uint256 i = 0; i < dataPoints.length; i++) {
            if (
                keccak256(abi.encodePacked(dataPoints[i].text)) !=
                keccak256(abi.encodePacked("Hello World!"))
            ) {
                return false;
            }
        }
        return true;
    }
}
