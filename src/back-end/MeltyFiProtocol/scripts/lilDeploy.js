
const hre = require("hardhat");

/**
 * Deploys a contract with the given name and arguments, using the provided deployer as the signer.
 *
 * @param {string} contractName - The name of the contract to deploy.
 * @param {any[]} args - The arguments to pass to the contract constructor.
 * @param {import('hardhat/types').Signer} deployer - The signer to use for deploying the contract.
 * @return {Promise<import('hardhat/types').Contract>} The deployed contract instance.
 */
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

	return contract;
}

async function main() {

	const [deployer, ...otherAccounts] = await hre.ethers.getSigners();

	const contractChocoChip = await deployContract('ChocoChip', [], deployer);

}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});

