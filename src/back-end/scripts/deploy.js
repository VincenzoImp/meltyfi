
async function deployContract(contractName, args, deployer) {

	console.log(`${contractName} is deploying...`);
	console.log(`Deployer address: ${deployer.address}`);

	const Contract = await hre.ethers.getContractFactory(contractName);
	const contract = await Contract.deploy(...args);
	await contract.deployed();

	console.log(`Contract address: ${contract.address}`);
	console.log(`Transaction hash: ${contract.deployTransaction.hash}`);
	console.log(`${contractName} deployed`);
	console.log();

	return contract.address;
}

async function main() {

	const [deployer, ...otherAccounts] = await hre.ethers.getSigners();

	const addressChocoChip = await deployContract('ChocoChip', [], deployer);

	const addressWonkaBar = await deployContract('WonkaBar', [], deployer);

	const addressTimelockController = await deployContract('TimelockController', [3600, [], [], deployer.address], deployer);
	const addressMeltyFiDAO = await deployContract('MeltyFiDAO', [addressChocoChip, addressTimelockController], deployer);

	const addressMeltyFiNFT = await deployContract('MeltyFiNFT', [addressChocoChip, addressWonkaBar, addressMeltyFiDAO], deployer);

}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});

