require("@nomicfoundation/hardhat-toolbox-viem");
require("dotenv").config(); // Load environment variables

module.exports = {
  solidity: {
    version: "0.8.27",  // 🔹 Solidity Version
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

  networks: {
    monadTestnet: {
      url: "https://testnet-rpc.monad.xyz", // Monad Testnet RPC
      chainId: 10143,
      accounts: [process.env.PRIVATE_KEY] // Wallet private key
    }
  },

  sourcify: {
    enabled: true,
    apiUrl: "https://sourcify-api-monad.blockvision.org",
    browserUrl: "https://testnet.monadexplorer.com"
  },

  etherscan: {
    enabled: false // 🔹 Etherscan Disabled
  }
};
