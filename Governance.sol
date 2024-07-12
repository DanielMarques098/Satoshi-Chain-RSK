// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISatoshiToken {
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
}

contract Governance {
    struct Proposal {
        uint id;
        string description;
        uint voteCount;
        mapping(address => bool) voted;
        uint endTime;
        bool executed;
    }

    uint public proposalCount;
    mapping(uint => Proposal) public proposals;
    address public admin;
    uint public votingDuration;
    ISatoshiToken public satoshiToken;
    uint public rewardAmount;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(address _satoshiToken, uint _votingDuration, uint _rewardAmount) {
        admin = msg.sender;
        satoshiToken = ISatoshiToken(_satoshiToken);
        votingDuration = _votingDuration;
        rewardAmount = _rewardAmount;
    }

    function createProposal(string memory _description) public {
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.description = _description;
        newProposal.endTime = block.timestamp + votingDuration;
    }

    function vote(uint _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.endTime, "Voting period ended");
        require(!proposal.voted[msg.sender], "You have already voted");

        proposal.voted[msg.sender] = true;
        proposal.voteCount++;

        // Recompensar o votante com tokens Satoshi
        require(satoshiToken.transfer(msg.sender, rewardAmount), "Reward transfer failed");
    }

    function executeProposal(uint _proposalId) public onlyAdmin {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.voteCount > 0, "No votes for the proposal");
        require(block.timestamp >= proposal.endTime, "Voting period not ended");

        // Implementar a lógica da proposta aqui

        proposal.executed = true;
    }
}
