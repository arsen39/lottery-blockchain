require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-tracer");
require("dotenv").config({ path: __dirname + "/.env" });

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.7",
        settings: {
          optimizer: {
            enabled: true,
            runs: 800,
          },
        },
      },
    ],
  },
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  networks: {
    hardhat: {
      forking: {
        // ** BSC **
        url: process.env.BSC_FORK_URL,
      },
    },
  },
  mocha: {
    timeout: 1000000000000000,
  },
};
