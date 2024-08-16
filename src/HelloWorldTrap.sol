// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

struct CollectOutput {
    string text;
}

contract HelloWorldTrap is ITrap{
    constructor() {}

    function collect() external view returns (bytes memory) {
        return abi.encode(CollectOutput({text: "Hello World!"}));
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure returns (bool, bytes memory) {
        for (uint256 i = 0; i < data.length; i++) {
            CollectOutput memory output = abi.decode(data[i], (CollectOutput));
            if (
                keccak256(abi.encodePacked(output.text)) !=
                keccak256(abi.encodePacked("Hello World!"))
            ) {
                return (true, bytes(abi.encode(output.text)));
            }
        }
        return (false, bytes(""));
    }
}
