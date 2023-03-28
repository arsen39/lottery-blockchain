const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const ADDRESS_ZERO = "0x0000000000000000000000000000000000000000";
const WETH = "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c";

describe("Common system test", function () {
  beforeEach(async function () {
    const signers = await ethers.getSigners();
    this.signers = signers;

    // System deployment
    const Access = await ethers.getContractFactory("Access");
    const access = await upgrades.deployProxy(Access, []);
    await access.deployed();
    this.access = access;

    const Random = await ethers.getContractFactory("Random");
    const random = await upgrades.deployProxy(Random, ["23232939298987"]);
    await random.deployed();
    this.random = random;

    const Exchanger = await ethers.getContractFactory("Exchanger");
    const exchanger = await upgrades.deployProxy(Exchanger, [access.address]);
    await exchanger.deployed();
    this.exchanger = exchanger;

    const Token = await ethers.getContractFactory("Token");
    const token = await upgrades.deployProxy(Token, [exchanger.address]);
    await token.deployed();
    this.token = token;

    const Passport = await ethers.getContractFactory("Passport");
    const passport = await upgrades.deployProxy(Passport, [access.address]);
    await passport.deployed();
    this.passport = passport;

    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await upgrades.deployProxy(Lottery, [access.address]);
    await lottery.deployed();
    this.lottery = lottery;

    // System setup
    await access.grantRole(
      ethers.utils.solidityKeccak256(["string"], ["GLOBAL_ADMIN_ROLE"]),
      signers[0].address
    );
    await access.grantRole(
      ethers.utils.solidityKeccak256(["string"], ["GLOBAL_MANAGER_ROLE"]),
      signers[0].address
    );
    await access.grantRole(
      ethers.utils.solidityKeccak256(["string"], ["SYSTEM_CONTRACT_ROLE"]),
      access.address
    );
    await access.grantRole(
      ethers.utils.solidityKeccak256(["string"], ["SYSTEM_CONTRACT_ROLE"]),
      random.address
    );
    await access.grantRole(
      ethers.utils.solidityKeccak256(["string"], ["SYSTEM_CONTRACT_ROLE"]),
      token.address
    );
    await access.grantRole(
      ethers.utils.solidityKeccak256(["string"], ["SYSTEM_CONTRACT_ROLE"]),
      exchanger.address
    );
    await access.grantRole(
      ethers.utils.solidityKeccak256(["string"], ["SYSTEM_CONTRACT_ROLE"]),
      passport.address
    );
    await access.grantRole(
      ethers.utils.solidityKeccak256(["string"], ["SYSTEM_CONTRACT_ROLE"]),
      lottery.address
    );

    await access.setAddressItem(
      ethers.utils.formatBytes32String("LOTTERY_ADDRESS"),
      lottery.address
    );
    await access.setAddressItem(
      ethers.utils.formatBytes32String("PASSPORT_ADDRESS"),
      passport.address
    );
    await access.setAddressItem(
      ethers.utils.formatBytes32String("UTILITY_TOKEN_ADDRESS"),
      token.address
    );
    await access.setAddressItem(
      ethers.utils.formatBytes32String("COMMUNITY_WALLET_ADDRESS"),
      signers[0].address
    );
    await access.setAddressItem(
      ethers.utils.formatBytes32String("RANDOM_ADDRESS"),
      random.address
    );

   // Additional setup for testing
    const router = await ethers.getContractAt(
      "IUniswapV2Router02",
      "0x10ED43C718714eb63d5aA57B78B54704E256024E"
    );
    this.router = router;
    const usdt = await ethers.getContractAt(
      "IERC20",
      "0x55d398326f99059ff775485246999027b3197955"
    );
    this.usdt = usdt;

    await router.swapExactETHForTokens(
      0,
      [WETH, usdt.address],
      signers[0].address,
      999999999999,
      { value: BigInt(100 * 1e18) }
    );

    await router
      .connect(signers[1])
      .swapExactETHForTokens(
        0,
        [WETH, usdt.address],
        signers[1].address,
        999999999999,
        { value: BigInt(100 * 1e18) }
      );
  });

  it("Basic flow test", async function () {
    const admin = this.signers[0];
    const user = this.signers[1];

    await this.passport.connect(user).register("Kitty");

    await this.usdt.connect(user).approve(this.token.address, BigInt(10000 * 1e18));
    await this.token.connect(user).deposit(BigInt(100 * 1e18), this.usdt.address);
    
    await this.token.connect(user).approve(this.lottery.address, BigInt(10000 * 1e18));
    await this.lottery.connect(user).bet("2645");
    await this.lottery.connect(user).bet("8542");
    await this.lottery.connect(user).bet("2087");
    await this.lottery.connect(user).bet("9152");

    await this.lottery.connect(admin).draw();

    await this.token.connect(user).withdraw(BigInt(500 * 1e18));

  });

  //** !!! AND SO ON... IT IS NECESSARY TO TEST 110% OF THE FUNCTIONALITY OF EACH CONTRACT !!! **//
});
