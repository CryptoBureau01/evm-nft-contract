require("dotenv").config({ path: "/root/evm-nft-contract/.env" });
require("dotenv").config({ path: "/root/evm-nft-contract/.envUser" });

const { ethers } = require("hardhat");
const path = require("path");
const contractABI = require(path.join(__dirname, "../artifacts/contracts/NFT.sol/MonadDogeNFT.json")).abi;

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
const RPC_URL = "https://testnet-rpc.monad.xyz";
const MINT_AMOUNT = BigInt(process.env.MINT_AMOUNT || "1"); // Convert to BigInt

if (!PRIVATE_KEY || !CONTRACT_ADDRESS) {
    console.error("[ERROR] Missing PRIVATE_KEY or CONTRACT_ADDRESS. Check .envUser and .env files.");
    process.exit(1);
}

async function mintNFT() {
    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
    const contract = new ethers.Contract(CONTRACT_ADDRESS, contractABI, wallet);

    try {
        console.log(`[INFO] Fetching mint price...`);
        const mintPrice = await contract.mintPrice(); // mintPrice is a BigInt
        const totalCost = mintPrice * MINT_AMOUNT; // Ensure both are BigInt

        console.log(`[INFO] Minting ${MINT_AMOUNT} NFT(s) from contract: ${CONTRACT_ADDRESS}`);
        console.log(`[INFO] Sending transaction with value: ${ethers.formatEther(totalCost.toString())} ETH...`);

        const tx = await contract.mintNFT(MINT_AMOUNT, { value: totalCost });
        console.log(`[SUCCESS] Minting transaction sent: ${tx.hash}`);
        await tx.wait();
        console.log(`[SUCCESS] Minted ${MINT_AMOUNT} NFT(s) successfully!`);
    } catch (error) {
        console.error("[ERROR] Minting failed:", error);
    }
}

mintNFT();
