const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const ADDRESS_ZERO = "0x0000000000000000000000000000000000000000";

describe("Exchanger", function () {
  beforeEach(async function () {
    const signers = await ethers.getSigners();
    this.signers = signers;

    const Access = await ethers.getContractFactory("Access");
    const access = await upgrades.deployProxy(Access, []);
    await access.deployed();
    this.access = access;

    const Exchanger = await ethers.getContractFactory("Exchanger");
    const exchanger = await upgrades.deployProxy(Exchanger, [access.address]);
    await exchanger.deployed();
    this.exchanger = exchanger;

    await access.setAddressItem(
      ethers.utils.formatBytes32String("UTILITY_TOKEN_ADDRESS"),
      signers[0].address
    );
  });

  it("should revert if not a token address calls deposit and withdraw function", async function () {
    await expect(
      this.exchanger
        .connect(this.signers[1])
        .deposit("0x55d398326f99059fF775485246999027B3197955", BigInt(1 * 1e18))
    ).to.be.revertedWith(
      "Exchanger: Invalid sender"
    );
    await expect(
      this.exchanger.connect(this.signers[1]).withdraw(this.signers[1].address, BigInt(1 * 1e18))
    ).to.be.revertedWith(
      "Exchanger: Invalid sender"
    );
  });

  it("should revert if the specified token is not supported", async function () {
    await expect(
      this.exchanger
        .connect(this.signers[0])
        .deposit("0x7EFaEf62fDdCCa950418312c6C91Aef321375A00", BigInt(1 * 1e18))
    ).to.be.revertedWith(
      "Exchanger: Invalid token"
    );
  });

  //** !!! AND SO ON... IT IS NECESSARY TO TEST 110% OF THE FUNCTIONALITY OF EACH CONTRACT !!! **//
});
