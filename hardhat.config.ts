import * as dotenv from 'dotenv'
dotenv.config()

import '@typechain/hardhat'
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import './tasks'

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHEREUM_SEPOLIA_RPC_URL = process.env.ETHEREUM_SEPOLIA_RPC_URL;
const POLYGON_MUMBAI_RPC_URL = process.env.POLYGON_MUMBAI_RPC_URL;
const OPTIMISM_GOERLI_RPC_URL = process.env.OPTIMISM_GOERLI_RPC_URL;
const ARBITRUM_TESTNET_RPC_URL = process.env.ARBITRUM_TESTNET_RPC_URL;
const AVALANCHE_FUJI_RPC_URL = process.env.AVALANCHE_FUJI_RPC_URL;

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]

  },
  networks: {
    hardhat: {
      chainId: 31337
    },
    ethereumSepolia: {
      url: ETHEREUM_SEPOLIA_RPC_URL !== undefined ? ETHEREUM_SEPOLIA_RPC_URL : 'https://rpc.sepolia.org',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111
    },
    polygonMumbai: {
      url: POLYGON_MUMBAI_RPC_URL !== undefined ? process.env.POLYGON_MUMBAI_RPC_URL : 'https://polygon-mumbai-pokt.nodies.app',
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 80001
    },
    optimismGoerli: {
      url: OPTIMISM_GOERLI_RPC_URL !== undefined ? OPTIMISM_GOERLI_RPC_URL : 'https://goerli.optimism.io',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 420,
    },
    arbitrumTestnet: {
      url: ARBITRUM_TESTNET_RPC_URL !== undefined ? ARBITRUM_TESTNET_RPC_URL : 'https://goerli-rollup.arbitrum.io/rpc',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 421613
    },
    avalancheFuji: {
      url: AVALANCHE_FUJI_RPC_URL !== undefined ? AVALANCHE_FUJI_RPC_URL : 'https://rpc.ankr.com/avalanche_fuji',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      chainId: 43113
    },
  },
  etherscan: {
    apiKey: {
      goerli: process.env.ETHERSCAN_API_KEY || '',
      sepolia: process.env.ETHERSCAN_API_KEY || '',
      polygonMumbai: process.env.POLYGON_API_KEY || '',
      avalancheFujiTestnet: process.env.AVALANCHE_API_KEY || '',
      'arbitrum-goerli': process.env.ARBITRUM_API_KEY || '',
      'optimism-goerli': process.env.OPTIMISTIC_API_KEY || '',
    },
    customChains: [
      {
        network: 'arbitrum-goerli',
        chainId: 421613,
        urls: {
          apiURL: 'https://api-goerli.arbiscan.io/api',
          browserURL: 'https://testnet.arbiscan.io/'
        }
      },
      {
        network: 'optimism-goerli',
        chainId: 420,
        urls: {
          apiURL: 'https://api-goerli-optimism.etherscan.io/api',
          browserURL: 'https://goerli-optimism.etherscan.io'
        }
      },
    ]
  }
};

export default config;