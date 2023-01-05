require("@nomicfoundation/hardhat-toolbox");

const ETHERSCAN_API_KEY = "";
const ALCHEMY_API_KEY = "kdzb_SLn00M1Be_qTSm0Vpu8S6NNsFx8";

const GOERLI_PRIVATE_KEY = "6c4c67e8de44c4b25652dd05c8855263d7ad4c79e7a1fd19b8068048dd64ca46";

const GOERLI_RPC_URL = `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`;

module.exports = {
	solidity: {
		version: "0.8.17",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200
			}
		}
	},
	networks: {
		goerli: {
			url: GOERLI_RPC_URL,
			accounts: [GOERLI_PRIVATE_KEY]
		},
		localhost: {
			url: "http://127.0.0.1:7545"
		}
	},
	etherscan: {
		apiKey: {
			goerli: ETHERSCAN_API_KEY,
		}
	}
};
