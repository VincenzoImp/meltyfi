const { expect } = require("chai");

describe("Chocochip", function () {
	it("Deploying", async function () {
		const [owner] = await ethers.getSigners();

		const Contract = await ethers.getContractFactory("ChocoChip");

		const contract = await Contract.deploy();

		const ownerBalance = await contract.balanceOf(owner.address);
		expect(await contract.totalSupply()).to.equal(ownerBalance);
	});
});
