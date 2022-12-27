require("@nomicfoundation/hardhat-toolbox");

const ALCHEMY_API_KEY = "kdzb_SLn00M1Be_qTSm0Vpu8S6NNsFx8";

const GOERLI_PRIVATE_KEY = "441ef19e9a92331e85edc1dfc44663ec0c6836a237976ddbdf3c6ef9d6cfbf4a";

const GOERLI_RPC_URL = `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`;

module.exports = {
	solidity: {
		version: "0.8.9",
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
	}
};
