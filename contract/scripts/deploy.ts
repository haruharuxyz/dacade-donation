import { ethers } from "hardhat";

async function main() {
  const Donation = await ethers.getContractFactory("Donation");
  const donation = await Donation.deploy();

  await donation.deployed();

  console.log(
    `Donation deployed to ${donation.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// 0xDe0524bf7EC4a8616ae26Ff9b28e124b121D2800