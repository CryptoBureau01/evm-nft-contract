const { ethers } = require("hardhat");

async function main() {
  const maxSupply = 5000; // Set your max supply

  const MonadDogeNFT = await ethers.getContractFactory("MonadDogeNFT");
  const monadDoge = await MonadDogeNFT.deploy(maxSupply);

  await monadDoge.deployed();

  console.log(`✅ MonadDogeNFT deployed at: ${monadDoge.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
