const hre = require("hardhat");

async function main() {
  const maxSupply = 5000; // Change if needed

  // Deploy contract
  const MonadDogeNFT = await hre.ethers.getContractFactory("MonadDogeNFT");
  const monadDoge = await MonadDogeNFT.deploy(maxSupply); // Correct deployment

  await monadDoge.waitForDeployment(); // Corrected function

  console.log(`✅ MonadDogeNFT deployed at: ${await monadDoge.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
