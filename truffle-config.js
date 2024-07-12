module.exports = {
  networks: {
    satoshiTestnet: {
      host: "127.0.0.1",
      port: 4444,
      network_id: "*", // Match any network id
      gas: 12000000
    },
    // outras redes...
  },
  compilers: {
    solc: {
      version: "0.8.20", // Versão específica do compilador Solidity
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
};
