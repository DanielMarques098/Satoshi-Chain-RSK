// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AtomicSwap {
    struct Swap {
        address payable initiator;
        address payable participant;
        uint256 value;
        uint256 refundTimestamp;
        bytes32 secretHash;
        bytes32 secret;
        bool initiated;
        bool redeemed;
        bool refunded;
    }

    mapping(bytes32 => Swap) public swaps;

    event Initiate(bytes32 indexed swapID, address indexed participant, uint256 value, uint256 refundTimestamp, bytes32 secretHash);
    event Redeem(bytes32 indexed swapID, bytes32 secret);
    event Refund(bytes32 indexed swapID);

    modifier onlyInitiator(bytes32 _swapID) {
        require(msg.sender == swaps[_swapID].initiator, "Only initiator can call this function");
        _;
    }

    modifier onlyParticipant(bytes32 _swapID) {
        require(msg.sender == swaps[_swapID].participant, "Only participant can call this function");
        _;
    }

    function initiate(bytes32 _swapID, address payable _participant, uint256 _refundTimestamp, bytes32 _secretHash) external payable {
        require(swaps[_swapID].initiated == false, "Swap already initiated");
        swaps[_swapID] = Swap({
            initiator: payable(msg.sender),
            participant: _participant,
            value: msg.value,
            refundTimestamp: _refundTimestamp,
            secretHash: _secretHash,
            secret: 0x0,
            initiated: true,
            redeemed: false,
            refunded: false
        });
        emit Initiate(_swapID, _participant, msg.value, _refundTimestamp, _secretHash);
    }

    function redeem(bytes32 _swapID, bytes32 _secret) external onlyParticipant(_swapID) {
        Swap storage swap = swaps[_swapID];
        require(swap.redeemed == false, "Swap already redeemed");
        require(swap.refunded == false, "Swap already refunded");
        require(sha256(abi.encodePacked(_secret)) == swap.secretHash, "Invalid secret");
        swap.secret = _secret;
        swap.redeemed = true;
        swap.participant.transfer(swap.value);
        emit Redeem(_swapID, _secret);
    }

    function refund(bytes32 _swapID) external onlyInitiator(_swapID) {
        Swap storage swap = swaps[_swapID];
        require(block.timestamp >= swap.refundTimestamp, "Refund not yet available");
        require(swap.redeemed == false, "Swap already redeemed");
        require(swap.refunded == false, "Swap already refunded");
        swap.refunded = true;
        swap.initiator.transfer(swap.value);
        emit Refund(_swapID);
    }
}
