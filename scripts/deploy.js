require("dotenv").config();
const fs = require("fs");
const { ethers } = require("hardhat");

async function main() {
  const maxSupply = 5000000000; // ✅ Max supply set to 5 Billion
  const baseURI = "https://gateway.pinata.cloud/ipfs/bafybeig7ckgnpsqefislvfye7gqmoun46w76a355tdxbmmlgms4bl25dsy/";

  console.log("[INFO] Deploying MonadDogeNFT...");

  const MonadDogeNFT = await ethers.getContractFactory("MonadDogeNFT");
  const monadDoge = await MonadDogeNFT.deploy(maxSupply, baseURI); // ✅ 2 arguments pass karein

  await monadDoge.waitForDeployment(); // ✅ Ethers v6 ke liye correct method

  const contractAddress = await monadDoge.getAddress();
  console.log(`✅ MonadDogeNFT deployed at: ${contractAddress}`);

  // ✅ Save contract address to .env file
  const envFilePath = ".env";
  let envConfig = "";
  
  if (fs.existsSync(envFilePath)) {
    envConfig = fs.readFileSync(envFilePath, "utf8");
  }

  // Replace existing CONTRACT_ADDRESS or add it
  if (envConfig.includes("CONTRACT_ADDRESS=")) {
    envConfig = envConfig.replace(/CONTRACT_ADDRESS=.*/g, `CONTRACT_ADDRESS=${contractAddress}`);
  } else {
    envConfig += `\nCONTRACT_ADDRESS=${contractAddress}`;
  }

  fs.writeFileSync(envFilePath, envConfig, "utf8");
  console.log("✅ Contract address saved to .env file!");
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});
