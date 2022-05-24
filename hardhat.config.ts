import "dotenv/config"
import "@nomiclabs/hardhat-etherscan"
import "@nomiclabs/hardhat-solhint"
import "@tenderly/hardhat-tenderly"
import "@nomiclabs/hardhat-waffle"
import "hardhat-abi-exporter"
import "hardhat-deploy"
import "hardhat-deploy-ethers"
import "hardhat-gas-reporter"
import "hardhat-spdx-license-identifier"
import "hardhat-typechain"
import "hardhat-watcher"
import "solidity-coverage"
import "./tasks"

import { HardhatUserConfig } from "hardhat/types"
import { removeConsoleLog } from "hardhat-preprocessor"

// Mumbai
//const API_URL = "https://polygon-mainnet.g.alchemy.com/v2/D-peaSeS3wbQWRMnjgM5OUQGihwUW3fT";
const API_URL = "https://polygon-mainnet.g.alchemy.com/v2/D-peaSeS3wbQWRMnjgM5OUQGihwUW3fT";
const PRIV_KEY = "4119713279c6b87c1778d0476e1e92e8db61cc84961f55e16281e865ad33cf76";
const PUBLIC_KEY = "0x483C60C602a6606CA0A3A14bE921Eee0175DEB6D";
const DEPLOYER_ACCOUNT = "0x483C60C602a6606CA0A3A14bE921Eee0175DEB6D";
const DEV_ACCOUNT = "i0x483C60C602a6606CA0A3A14bE921Eee0175DEB6D";
const PRIVATE_KEY = "4119713279c6b87c1778d0476e1e92e8db61cc84961f55e16281e865ad33cf76";
const POLYSCAN_API_KEY = "JY3WFIA8YTPJPPMZS1MQM24DATGJ5YZSC4";
const FORKING = false;
const HARDHAT_MAX_MEMORY = 4096;
const HARDHAT_SHOW_STACK_TRACES = true;
const HARDHAT_VERBOSE = true;
const REPORT_GAS = false;

// const accounts = {
//   mnemonic: process.env.MNEMONIC || "test test test test test test test test test test test junk",
//   // accountsBalance: "990000000000000000000",
// }

const config: HardhatUserConfig = {
	abiExporter: {
    path: "./abi",
    clear: false,
    flat: true,
    // only: [],
    // except: []
  },
	defaultNetwork: "hardhat",
	etherscan: {
    apiKey: `${POLYSCAN_API_KEY}`,
  },

  mocha: {
    timeout: 20000,
  },
  // CHIGAG 1: need to add deployer and dev accounts to list below for each network!!!
  namedAccounts: {
    deployer: {
      default: 0,
      80001: `${DEPLOYER_ACCOUNT}`,
      97: `${DEPLOYER_ACCOUNT}`,

    },
    dev: {
      // Default to 1
      default: 1,
      80001: `${DEV_ACCOUNT}`,
      97: `${DEV_ACCOUNT}`,
      // dev address mainnet
      // 1: "",
    },
  },
  networks: {
		localhost: {
      url: 'http://localhost:8545/rpc',
      timeout: 600000,
      gasPrice: 900000000,
      gas: 21000000,
      accounts: [ '0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e' ],
		},
		// mainnet: {
    //   url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
    //   accounts: process.env.MNEMONIC,
    //   gasPrice: 120 * 1000000000,
    //   chainId: 1,
    // },
    // hardhat: {
    //   forking: {
    //     enabled: process.env.FORKING === "true",
    //     url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
    //   },
    //   live: false,
    //   saveDeployments: true,
    //   tags: ["test", "local"],
    // },
    // ropsten: {
    //   url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
    //   accounts,
    //   chainId: 3,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasPrice: 5000000000,
    //   gasMultiplier: 2,
    // },
    // rinkeby: {
    //   url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
    //   accounts,
    //   chainId: 4,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasPrice: 5000000000,
    //   gasMultiplier: 2,
    // },
    // goerli: {
    //   url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
    //   accounts,
    //   chainId: 5,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasPrice: 5000000000,
    //   gasMultiplier: 2,
    // },
    // kovan: {
    //   url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
    //   accounts,
    //   chainId: 42,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasPrice: 20000000000,
    //   gasMultiplier: 2,
    // },
    // moonbase: {
    //   url: "https://rpc.testnet.moonbeam.network",
    //   accounts,
    //   chainId: 1287,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gas: 5198000,
    //   gasMultiplier: 4,
    // },
    // fantom: {
    //   url: "https://rpcapi.fantom.network",
    //   accounts,
    //   chainId: 250,
    //   live: true,
    //   saveDeployments: true,
    //   gasPrice: 22000000000,
    // },
    // "fantom-testnet": {
    //   url: "https://rpc.testnet.fantom.network",
    //   accounts,
    //   chainId: 4002,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasMultiplier: 2,
    // },
     matic: {
       url: `${API_URL}`,
       accounts: [PRIV_KEY],
       chainId: 137,
       live: true,
       saveDeployments: true,
     },
     mumbai: {
       url: `${API_URL}`,
       accounts: [PRIV_KEY],
       chainId: 80001,
			 live: true,
       saveDeployments: true,
    },
    // xdai: {
    //   url: "https://rpc.xdaichain.com",
    //   accounts,
    //   chainId: 100,
    //   live: true,
    //   saveDeployments: true,
    // },
   /* bsc: {
      url: "https://bsc-dataseed.binance.org",
      accounts: [process.env.MNEMONIC],
      chainId: 56,
      live: true,
      saveDeployments: true,
    },
    "bsc-testnet": {
      url: "https://data-seed-prebsc-2-s3.binance.org:8545",
      accounts: [process.env.MNEMONIC],
      chainId: 97,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
      gasMultiplier: 2,
    },*/
    // heco: {
    //   url: "https://http-mainnet.hecochain.com",
    //   accounts,
    //   chainId: 128,
    //   live: true,
    //   saveDeployments: true,
    // },
    // "heco-testnet": {
    //   url: "https://http-testnet.hecochain.com",
    //   accounts,
    //   chainId: 256,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasMultiplier: 2,
    // },
    // avalanche: {
    //   url: "https://api.avax.network/ext/bc/C/rpc",
    //   accounts,
    //   chainId: 43114,
    //   live: true,
    //   saveDeployments: true,
    //   gasPrice: 470000000000,
    // },
    // fuji: {
    //   url: "https://api.avax-test.network/ext/bc/C/rpc",
    //   accounts,
    //   chainId: 43113,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasMultiplier: 2,
    // },
    // harmony: {
    //   url: "https://api.s0.t.hmny.io",
    //   accounts,
    //   chainId: 1666600000,
    //   live: true,
    //   saveDeployments: true,
    //   gasMultiplier: 2,
    // },
    // "harmony-testnet": {
    //   url: "https://api.s0.b.hmny.io",
    //   accounts,
    //   chainId: 1666700000,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasMultiplier: 2,
    // },
    // okex: {
    //   url: "https://exchainrpc.okex.org",
    //   accounts,
    //   chainId: 66,
    //   live: true,
    //   saveDeployments: true,
    // },
    // "okex-testnet": {
    //   url: "https://exchaintestrpc.okex.org",
    //   accounts,
    //   chainId: 65,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasMultiplier: 2,
    // },
    // arbitrum: {
    //   url: "https://arb1.arbitrum.io/rpc",
    //   accounts,
    //   chainId: 42161,
    //   live: true,
    //   saveDeployments: true,
    //   blockGasLimit: 700000,
    // },
    // "arbitrum-testnet": {
    //   url: "https://kovan3.arbitrum.io/rpc",
    //   accounts,
    //   chainId: 79377087078960,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasMultiplier: 2,
    // },
    // celo: {
    //   url: "https://forno.celo.org",
    //   accounts,
    //   chainId: 42220,
    //   live: true,
    //   saveDeployments: true,
    // },
    // palm: {
    //   url: "https://palm-mainnet.infura.io/v3/da5fbfafcca14b109e2665290681e267",
    //   accounts,
    //   chainId: 11297108109,
    //   live: true,
    //   saveDeployments: true,
    // },
    // "palm-testnet": {
    //   url: "https://palm-testnet.infura.io/v3/da5fbfafcca14b109e2665290681e267",
    //   accounts,
    //   chainId: 11297108099,
    //   live: true,
    //   saveDeployments: true,
    //   tags: ["staging"],
    //   gasMultiplier: 2,
    // },
    // moonriver: {
    //   url: "https://rpc.moonriver.moonbeam.network",
    //   accounts,
    //   chainId: 1285,
    //   live: true,
    //   saveDeployments: true,
    // },
    // fuse: {
    //   url: "https://rpc.fuse.io",
    //   accounts,
    //   chainId: 122,
    //   live: true,
    //   saveDeployments: true,
    // },
    // clover: {
    //   url: "https://rpc-ivy.clover.finance",
    //   accounts,
    //   chainId: 1024,
    //   live: true,
    //   saveDeployments: true,
    // },
    // telos: {
    //   url: "https://rpc1.us.telos.net/evm",
    //   accounts,
    //   chainId: 40,
    //   live: true,
    //   saveDeployments: true,
    // },
    // moonbeam: {
    //   url: "https://rpc.api.moonbeam.network",
    //   accounts,
    //   chainId: 1284,
    //   live: true,
    //   saveDeployments: true,
    // }, 
	},
  paths: {
    artifacts: "artifacts",
    cache: "cache",
    deploy: "deploy",
    deployments: "deployments",
    imports: "imports",
    sources: "contracts",
    tests: "test",
  },
  preprocess: {
    eachLine: removeConsoleLog((bre) => bre.network.name !== "hardhat" && bre.network.name !== "localhost"),
  },
	solidity: {
    compilers: [
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.13",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
        },
      },
    ],
  },

  spdxLicenseIdentifier: {
    overwrite: false,
    runOnCompile: true,
  },
  tenderly: {
    project: process.env.TENDERLY_PROJECT!,
    username: process.env.TENDERLY_USERNAME!,
  },
  typechain: {
    outDir: "types",
    target: "ethers-v5",
  },
  watcher: {
    compile: {
      tasks: ["compile"],
      files: ["./contracts"],
      verbose: true,
    },
  },
}

export default config
