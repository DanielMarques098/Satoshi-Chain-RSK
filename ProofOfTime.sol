// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProofOfTime {
    uint256 public lastBlockTime;
    uint256 public blockInterval;

    constructor(uint256 _blockInterval) {
        blockInterval = _blockInterval; // Adjusted for shorter interval, e.g., 60 seconds
        lastBlockTime = block.timestamp;
    }

    modifier verifyTime() {
        require(block.timestamp >= lastBlockTime + blockInterval, "Block interval not met");
        _;
        lastBlockTime = block.timestamp;
    }

    function canGenerateBlock() public view returns (bool) {
        return block.timestamp >= lastBlockTime + blockInterval;
    }
}
