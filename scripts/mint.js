require("dotenv").config({ path: "/root/evm-nft-contract/.env" });
require("dotenv").config({ path: "/root/evm-nft-contract/.envUser" });

const { ethers } = require("hardhat");
const path = require("path");
const contractABI = require(path.join(__dirname, "../artifacts/contracts/NFT.sol/MonadDogeNFT.json")).abi;

const PRIVATE_KEY = process.env.PRIVATE_KEY; // User's private key from .envUser
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS; // Contract address from .env
const RPC_URL = "https://testnet-rpc.monad.xyz"; // Monad Testnet RPC
const MINT_AMOUNT = parseInt(process.env.MINT_AMOUNT || "1"); // Default to 1 if not provided

if (!PRIVATE_KEY || !CONTRACT_ADDRESS) {
    console.error("[ERROR] Missing PRIVATE_KEY or CONTRACT_ADDRESS. Check .envUser and .env files.");
    process.exit(1);
}

async function mintNFT() {
    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
    const contract = new ethers.Contract(CONTRACT_ADDRESS, contractABI, wallet);

    try {
        console.log(`[INFO] Minting ${MINT_AMOUNT} NFT(s) from contract: ${CONTRACT_ADDRESS}`);
        console.log(`[INFO] Sending transaction...`);

        for (let i = 0; i < MINT_AMOUNT; i++) {
            const tx = await contract.mint(wallet.address);
            console.log(`[SUCCESS] Minting transaction sent: ${tx.hash}`);
            await tx.wait();
            console.log(`[SUCCESS] NFT #${i + 1} Minted Successfully!`);
        }
    } catch (error) {
        console.error("[ERROR] Minting failed:", error);
    }
}

mintNFT();
