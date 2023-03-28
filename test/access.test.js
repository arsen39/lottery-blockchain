const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const ADDRESS_ZERO = "0x0000000000000000000000000000000000000000";

describe("Access test", function () {
  beforeEach(async function () {
    const signers = await ethers.getSigners();
    this.signers = signers;

    const Access = await ethers.getContractFactory("Access");
    const access = await upgrades.deployProxy(Access, []);
    await access.deployed();
    this.access = access;
  });

  it("should have default role", async function () {
    const { access, signers } = this;
    expect(await access.owner()).to.equal(signers[0].address);
  });

  it('should grant and revoke roles', async function () {
    const { access, signers } = this;
    const role = ethers.utils.solidityKeccak256(["string"], ["GLOBAL_ADMIN_ROLE"]);
    await access.grantRole(role, signers[1].address);
    expect(await access.hasRole(role, signers[1].address)).to.be.true;
    await access.revokeRole(role, signers[1].address);
    expect(await access.hasRole(role, signers[1].address)).to.be.false;
  });

  it('should change address item', async function () {
    const { access, signers } = this;
    const key = ethers.utils.solidityKeccak256(["string"], ["GLOBAL_ADMIN_ADDRESS"]);
    await access.setAddressItem(key, signers[0].address);
    expect(await access.addressBook(key)).to.equal(signers[0].address);
  });

  //** !!! AND SO ON... IT IS NECESSARY TO TEST 110% OF THE FUNCTIONALITY OF EACH CONTRACT !!! **//

});
