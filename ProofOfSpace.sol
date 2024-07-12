// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProofOfSpace {
    struct Plot {
        uint256 size;
        string proof;
        bool exists;
    }

    mapping(address => Plot) public plots;
    uint256 public totalPlots;

    event PlotCreated(address indexed user, uint256 size, string proof);
    event PlotVerified(address indexed user, string proof, bool valid);

    function createPlot(uint256 _size, string memory _proof) public {
        require(!plots[msg.sender].exists, "Plot already exists");
        plots[msg.sender] = Plot(_size, _proof, true);
        totalPlots += _size;
        emit PlotCreated(msg.sender, _size, _proof);
    }

    function verifyPlot(address _user, string memory _challenge) public returns (bool) {
        Plot memory plot = plots[_user];
        require(plot.exists, "Plot does not exist");
        bool valid = keccak256(abi.encodePacked(plot.proof, _challenge)) < keccak256(abi.encodePacked(_challenge));
        emit PlotVerified(_user, plot.proof, valid);
        return valid;
    }
}
