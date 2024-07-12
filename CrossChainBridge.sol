// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossChainBridge {
    address public admin;
    address public tokenWBTC;
    address public tokenUSDC;
    address public tokenUSDT;
    mapping(bytes32 => bool) public processedNonces;

    event Transfer(
        address from,
        address to,
        uint amount,
        uint date,
        bytes32 nonce,
        string destinationChain,
        string tokenSymbol
    );

    constructor(address _tokenWBTC, address _tokenUSDC, address _tokenUSDT) {
        admin = msg.sender;
        tokenWBTC = _tokenWBTC;
        tokenUSDC = _tokenUSDC;
        tokenUSDT = _tokenUSDT;
    }

    function bridgeTokens(address to, uint amount, bytes32 nonce, string memory destinationChain, string memory tokenSymbol) external {
        require(processedNonces[nonce] == false, "transfer already processed");
        processedNonces[nonce] = true;

        if (keccak256(abi.encodePacked(tokenSymbol)) == keccak256(abi.encodePacked("WBTC"))) {
            IERC20(tokenWBTC).transferFrom(msg.sender, address(this), amount);
        } else if (keccak256(abi.encodePacked(tokenSymbol)) == keccak256(abi.encodePacked("USDC"))) {
            IERC20(tokenUSDC).transferFrom(msg.sender, address(this), amount);
        } else if (keccak256(abi.encodePacked(tokenSymbol)) == keccak256(abi.encodePacked("USDT"))) {
            IERC20(tokenUSDT).transferFrom(msg.sender, address(this), amount);
        } else {
            revert("unsupported token");
        }

        emit Transfer(msg.sender, to, amount, block.timestamp, nonce, destinationChain, tokenSymbol);
    }

    function releaseTokens(address to, uint amount, bytes32 nonce, string memory tokenSymbol) external {
        require(msg.sender == admin, "only admin can release tokens");
        require(processedNonces[nonce] == false, "transfer already processed");
        processedNonces[nonce] = true;

        if (keccak256(abi.encodePacked(tokenSymbol)) == keccak256(abi.encodePacked("WBTC"))) {
            IERC20(tokenWBTC).transfer(to, amount);
        } else if (keccak256(abi.encodePacked(tokenSymbol)) == keccak256(abi.encodePacked("USDC"))) {
            IERC20(tokenUSDC).transfer(to, amount);
        } else if (keccak256(abi.encodePacked(tokenSymbol)) == keccak256(abi.encodePacked("USDT"))) {
            IERC20(tokenUSDT).transfer(to, amount);
        } else {
            revert("unsupported token");
        }
    }
}
