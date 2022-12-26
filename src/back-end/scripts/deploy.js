const { ethers } = require("hardhat");

async function deployContract(deployer, contractName, ...args) {

	console.log(`Deploying ${contractName} with the account: ${deployer.address}`);

	const Contract = await ethers.getContractFactory(contractName);
	const contract = await Contract.deploy(...args);

	console.log(`${contractName} address: ${contract.address}`);
	console.log(`${contractName} deployed at txhash: ${contract.deployTransaction.hash}`);
	console.log();

	return contract.address;
}

async function main() {

	const [deployer, ...otherAccounts] = await ethers.getSigners();

	const addressChocoChip = await deployContract(deployer, 'ChocoChip');

	const addressWonkaBar = await deployContract(deployer, 'WonkaBar');

	//const addressTimelockController = await deployContract(deployer, 'TimelockController', 3600, [], [], deployer.address);
	//const addressMeltyFiDAO = await deployContract(deployer, 'MeltyFiDAO', addressChocoChip, addressTimelockController);

	const addressMeltyFiDAO = deployer.address

	const addressMeltyFiNFT = await deployContract(deployer, 'MeltyFiNFT', addressChocoChip, addressWonkaBar, addressMeltyFiDAO);

}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});