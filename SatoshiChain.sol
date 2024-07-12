// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProofOfSpace.sol";
import "./ProofOfTime.sol";
import "./PegSystem.sol";
import "./Governance.sol";

contract SatoshiChain is ProofOfSpace, ProofOfTime, PegSystem, Governance {
    struct Block {
        uint256 blockNumber;
        address miner;
        string proof;
        uint256 timestamp;
        string message; // Added message field
    }

    Block[] public blockchain;

    event BlockCreated(uint256 blockNumber, address miner, string proof, uint256 timestamp, string message);

    constructor(
        uint256 _blockInterval,
        address[] memory _signers,
        uint _requiredSignatures,
        address _satoshiToken,
        uint _votingDuration,
        uint _rewardAmount
    )
        ProofOfTime(_blockInterval)
        PegSystem(_signers, _requiredSignatures)
        Governance(_satoshiToken, _votingDuration, _rewardAmount)
    {}

    function createBlock(string memory _challenge, string memory _message) public verifyTime {
        require(verifyPlot(msg.sender, _challenge), "Invalid plot proof");

        Block memory newBlock = Block({
            blockNumber: blockchain.length + 1,
            miner: msg.sender,
            proof: plots[msg.sender].proof,
            timestamp: block.timestamp,
            message: _message // Store the message in the block
        });

        blockchain.push(newBlock);
        emit BlockCreated(newBlock.blockNumber, newBlock.miner, newBlock.proof, newBlock.timestamp, newBlock.message);
    }

    function getBlock(uint256 _index) public view returns (Block memory) {
        require(_index < blockchain.length, "Block does not exist");
        return blockchain[_index];
    }
}
