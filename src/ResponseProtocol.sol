// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract ResponseProtocol {
    uint256 private balance;
    uint256 public blockNumber;

    event ResponseCallback(uint256 blockNumber, address sender);
    event HelloWorld(string text, address sender);

    constructor() {
        balance = 9999;
    }

    function getBalance() external view returns (uint256) {
        return balance;
    }

    function setBalance(uint256 _balance) external {
        balance = _balance;
    }

    function responseCallback(uint256 _blockNumber) external {
        blockNumber = _blockNumber;

        emit ResponseCallback(_blockNumber, msg.sender);
    }

    function helloworld(string memory text) external{
        emit HelloWorld(text, msg.sender);
    }
}
