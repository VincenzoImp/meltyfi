require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

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
			url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
			accounts: [process.env.GOERLI_PRIVATE_KEY]
		},
		localhost: {
			url: "http://127.0.0.1:7545"
		}
	},
	etherscan: {
		apiKey: process.env.ETHERSCAN_API_KEY
	}
};
