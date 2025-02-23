const { ethers } = require("hardhat");

async function main() {
  const maxSupply = 5000; // Set your max supply

  const MonadDogeNFT = await ethers.getContractFactory("MonadDogeNFT");
  const monadDoge = await MonadDogeNFT.deploy(maxSupply);

  await monadDoge.waitForDeployment(); // Correct function for Ethers v6

  console.log(`✅ MonadDogeNFT deployed at: ${await monadDoge.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

