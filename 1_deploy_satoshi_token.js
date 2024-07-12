const SatoshiToken = artifacts.require("SatoshiToken");

module.exports = function(deployer) {
  const initialSupply = web3.utils.toWei('1000000', 'ether'); // 1 milhão de tokens Satoshi
  deployer.deploy(SatoshiToken, initialSupply);
};
