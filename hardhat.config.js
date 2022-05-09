require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require('dotenv').config();



module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat : {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
        blocknumber: 14638929,
      }
    }
  }
};
