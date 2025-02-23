# EVM-NFT-Contract
Evm NFT Contract ( Testing : monad-nft ) with CryptoBureau 


# Monad Testnet NFT Contract Deployment Guide

```
git clone https://github.com/CryptoBureau01/evm-nft-contract.git && cd evm-nft-contract.git
```


## Prerequisites
Prerequisites

Before starting, the user should add their private key to the `.env` file. This should be the private key of the wallet that will be used to deploy the contract.

Ensure you have Node.js and npm installed:
```sh
node -v   # Check Node.js version
npm -v    # Check npm version
```

### Step 1: Install Hardhat

First, install Hardhat globally (if not already installed):
```sh
npm install -g hardhat
```

### Step 2: Install Project Dependencies

Navigate to your project directory and install the required dependencies:
```sh
npm install
```

### Step 3: Compile the Contract

Run the following command to compile your Solidity contracts:
```sh
npx hardhat compile
```

### Step 4: Deploy the Contract

Use the Hardhat script to deploy your contract to the Monad Testnet:
```sh
npx hardhat run scripts/deploy.js --network monadTestnet
```

After execution, you will receive the contract address. Note it down for verification.

### Step 5: Verify the Contract

Use the following command to verify your contract on Sourcify:
```sh
npx hardhat verify --network monadTestnet <CONTRACT_ADDRESS>
```
Replace `<CONTRACT_ADDRESS>` with the actual contract address obtained from the deployment step.

Once verified, you will receive a link to view your contract on the Monad Testnet Explorer.

## Conclusion

You have successfully deployed and verified your NFT contract on the Monad Testnet. If you encounter any issues, ensure all dependencies are installed correctly and that you are using the correct network configurations.

