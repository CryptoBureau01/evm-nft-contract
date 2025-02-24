require("dotenv").config();
const fs = require("fs");
const { ethers } = require("hardhat");

async function main() {
  const maxSupply = 5000000000; // ✅ Max supply set to 5 Billion
  const mintPrice = ethers.parseEther("1.0"); // ✅ Mint price set to 1 MON
  const baseURI = "https://gateway.pinata.cloud/ipfs/bafybeig7ckgnpsqefislvfye7gqmoun46w76a355tdxbmmlgms4bl25dsy/";

  console.log("[INFO] Deploying MonadDogeNFT...");

  const MonadDogeNFT = await ethers.getContractFactory("MonadDogeNFT");
  const monadDoge = await MonadDogeNFT.deploy(maxSupply, mintPrice, baseURI); // ✅ 3 arguments pass karein

  await monadDoge.waitForDeployment(); // ✅ Ethers v6 ke liye correct method

  const contractAddress = await monadDoge.getAddress();
  console.log(`✅ MonadDogeNFT deployed at: ${contractAddress}`);

  // ✅ Define .envUser file path
  const envUserFilePath = ".envUser";

  try {
    let envUserConfig = "";

    // ✅ Read existing .envUser file if it exists
    if (fs.existsSync(envUserFilePath)) {
      envUserConfig = fs.readFileSync(envUserFilePath, "utf8");
    }

    // ✅ Replace existing CONTRACT_ADDRESS or add it
    if (envUserConfig.includes("CONTRACT_ADDRESS=")) {
      envUserConfig = envUserConfig.replace(/CONTRACT_ADDRESS=.*/g, `CONTRACT_ADDRESS=${contractAddress}`);
    } else {
      envUserConfig += `\nCONTRACT_ADDRESS=${contractAddress}`;
    }

    // ✅ Write back to .envUser file
    fs.writeFileSync(envUserFilePath, envUserConfig.trim() + "\n", "utf8");
    console.log("✅ Contract address saved successfully in .envUser!");

  } catch (error) {
    console.error("❌ [ERROR] Failed to save contract address in .envUser!", error);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exit(1);
});
