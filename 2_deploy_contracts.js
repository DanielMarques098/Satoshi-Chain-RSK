const SatoshiChain = artifacts.require("SatoshiChain");
const SatoshiToken = artifacts.require("SatoshiToken");
const Governance = artifacts.require("Governance");
const Updater = artifacts.require("Updater");
const CrossChainBridge = artifacts.require("CrossChainBridge");
const AtomicSwap = artifacts.require("AtomicSwap");

module.exports = async function(deployer, network, accounts) {
    const blockInterval = 60; // Intervalo de bloco ajustado para 60 segundos
    const signers = accounts.slice(0, 3); // Use as primeiras 3 contas como signatários
    const requiredSignatures = 2;
    const votingDuration = 7 * 24 * 60 * 60; // Duração da votação em segundos (7 dias)
    const rewardAmount = 100; // Quantidade de tokens de recompensa por voto

    // Endereços dos tokens existentes na rede principal (Mainnet)
    const wbtcTokenAddress = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"; // WBTC
    const usdcTokenAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eb48"; // USDC
    const usdtTokenAddress = "0xdAC17F958D2ee523a2206206994597C13D831ec7"; // USDT

    // Atualize aqui com os nomes do token e símbolo apropriados
    const tokenName = "Satoshi Token";
    const tokenSymbol = "SAT";

    await deployer.deploy(SatoshiToken, tokenName, tokenSymbol);
    const satoshiTokenInstance = await SatoshiToken.deployed();

    await deployer.deploy(Governance, satoshiTokenInstance.address, votingDuration, rewardAmount);
    const governanceInstance = await Governance.deployed();

    await deployer.deploy(
        SatoshiChain,
        blockInterval,
        signers,
        requiredSignatures,
        satoshiTokenInstance.address,
        votingDuration,
        rewardAmount
    );

    await deployer.deploy(Updater);

    // Deploy CrossChainBridge com os endereços dos tokens existentes
    await deployer.deploy(CrossChainBridge, wbtcTokenAddress, usdcTokenAddress, usdtTokenAddress);

    // Deploy AtomicSwap
    await deployer.deploy(AtomicSwap);
};
