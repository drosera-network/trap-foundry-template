// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

// The purpose of this script is to provide the user with a sandbox to deploy other contracts on-chain or interact with the blockchain.
// command: forge script scripts/Sandbox.s.sol --sig "main()" --fork-url $RPC_URL  --private-key $PRIVATE_KEY --broadcast -vvvv
contract Sandbox is Script, Test {
    function main() external view {
        console.log("Hello World!");
    }
}
