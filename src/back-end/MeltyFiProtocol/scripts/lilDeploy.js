
const hre = require("hardhat");
const fs = require('fs');

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

	const row = `${contractName} ${contract.address}`;
	for (let i = 0; i < args.length; i++) {
		row += ` ${args[i]}`;
	}
	fs.appendFileSync('lilResult.txt', row);

	return contract;
}

async function main() {

	fs.writeFileSync('lilResult.txt', '');
	const [deployer, ...otherAccounts] = await hre.ethers.getSigners();

	const contractChocoChip = await deployContract('MeltyFiNFT', ['0xa07afF9b3691C653724eB09e922ae876cd737616', '0x290136c17204547E0322C12EA6A8E975a45e0820', '0x5b9AFB5BCBcC5fe37546907098fA4800B3bb9e42'], deployer);

}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});

