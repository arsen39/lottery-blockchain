const { getImplementationAddress } = require("@openzeppelin/upgrades-core");
const { ethers, upgrades } = require("hardhat");
const { waitBlocks } = require("../utils/blockWaiter");

async function main() {
  const signers = await ethers.getSigners();

  // DEPLOY
  const Random = await ethers.getContractFactory("Random");
  const random = await upgrades.deployProxy(Random, ["13249893565984949"]);
  await random.deployed();
  await waitBlocks(5);
  const randomImpl = await getImplementationAddress(
    ethers.provider,
    random.address
  );
  console.log(`Random deployed to: ${random.address} => ${randomImpl}`);
  await run("verify:verify", {
    address: randomImpl,
    contract: "contracts/Random.sol:Random",
  });
  // ...AND SO ON FOR ALL CONTRACTS...

  // SETUP

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
  //...
  await access.setAddressItem(
    ethers.utils.formatBytes32String("LOTTERY_ADDRESS"),
    lottery.address
  );
  // ...AND SO ON FOR ALL CONTRACTS...

  console.log("DONE!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
