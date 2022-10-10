require("@nomicfoundation/hardhat-toolbox");
const projectId="badaada1743148058fee1ea9539160ed"
const fs = require('fs')
// const keyData  = fs.readdirSync('./p-key.txt',{
//   encoding:"utf8",flag:"r"
// });
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337, //config standard
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${projectId}`,
      accounts:["4d5a56483458fa7ab580d6e42470db091a40a23f67f7fc38b30443cf2dbfe8ee"]
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${projectId}`,
      accounts:["4d5a56483458fa7ab580d6e42470db091a40a23f67f7fc38b30443cf2dbfe8ee"]
    },
  },
  solidity: {
    version:"0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
};
