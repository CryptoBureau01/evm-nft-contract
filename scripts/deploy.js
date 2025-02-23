require("dotenv").config();
const fs = require("fs");
const { ethers } = require("hardhat");

async function main() {
  const maxSupply = 5000; // Set your max supply

  const MonadDogeNFT = await ethers.getContractFactory("MonadDogeNFT");
  const monadDoge = await MonadDogeNFT.deploy(maxSupply);

  await monadDoge.waitForDeployment(); // Correct function for Ethers v6

  const contractAddress = await monadDoge.getAddress();
  console.log(`✅ MonadDogeNFT deployed at: ${contractAddress}`);

  // Save contract address to .env file
  const envFilePath = ".env";
  const envConfig = fs.readFileSync(envFilePath, "utf8");

  // Replace existing CONTRACT_ADDRESS or add it
  let newEnvConfig;
  if (envConfig.includes("CONTRACT_ADDRESS=")) {
      newEnvConfig = envConfig.replace(/CONTRACT_ADDRESS=.*/g, `CONTRACT_ADDRESS=${contractAddress}`);
  } else {
      newEnvConfig = envConfig + `\nCONTRACT_ADDRESS=${contractAddress}`;
  }

  fs.writeFileSync(envFilePath, newEnvConfig, "utf8");
  console.log("✅ Contract address saved to .env file!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
