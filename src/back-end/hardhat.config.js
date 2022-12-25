require("@nomiclabs/hardhat-waffle");

const ALCHEMY_API_KEY = "kdzb_SLn00M1Be_qTSm0Vpu8S6NNsFx8";

const GOERLI_PRIVATE_KEY = "cda1688f66a768462415622707b73e1a718c98ee8606d7cac807b61ba954df15";

const GOERLI_RPC_URL = `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`;

module.exports = {
	solidity: "0.8.9",
	networks: {
		goerli: {
			url: GOERLI_RPC_URL,
			accounts: [GOERLI_PRIVATE_KEY]
		}
	}
};
