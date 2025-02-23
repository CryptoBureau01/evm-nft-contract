require("dotenv").config({ path: "/root/evm-nft-contract/.envUser" }); // ✅ Load only .envUser

const { ethers } = require("hardhat");
const path = require("path");
const contractABI = require(path.join(__dirname, "../artifacts/contracts/NFT.sol/MonadDogeNFT.json")).abi;

// ✅ Fetch values from .envUser
const USER_PRIVATE_KEY = process.env.PRIVATE_KEY;  
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS; 
const RPC_URL = "https://testnet-rpc.monad.xyz"; 
const MINT_AMOUNT = parseInt(process.env.MINT_AMOUNT || "1"); // Default: 1 NFT

if (!USER_PRIVATE_KEY || !CONTRACT_ADDRESS) {
    console.error("[ERROR] Missing PRIVATE_KEY or CONTRACT_ADDRESS. Check .envUser file.");
    process.exit(1);
}

async function mintNFT() {
    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const wallet = new ethers.Wallet(USER_PRIVATE_KEY, provider); // ✅ Uses the user’s wallet
    const contract = new ethers.Contract(CONTRACT_ADDRESS, contractABI, wallet);

    console.log(`[DEBUG] Using wallet address: ${wallet.address}`);

    try {
        console.log("[INFO] Fetching mint price...");
        const mintPrice = await contract.mintPrice();
        const totalCost = mintPrice * BigInt(MINT_AMOUNT); // ✅ Correctly handling BigInt conversion

        console.log(`[INFO] Minting ${MINT_AMOUNT} NFT(s) from contract: ${CONTRACT_ADDRESS}`);
        console.log(`[INFO] Sending transaction with value: ${ethers.formatEther(totalCost)} ETH...`);

        const tx = await contract.mintNFT(MINT_AMOUNT, { value: totalCost });
        console.log(`[SUCCESS] Minting transaction sent: ${tx.hash}`);

        await tx.wait();
        console.log(`[SUCCESS] Minted ${MINT_AMOUNT} NFT(s) successfully!`);
    } catch (error) {
        console.error("[ERROR] Minting failed:", error);
    }
}

mintNFT();

