# !/bin/bash

curl -s https://raw.githubusercontent.com/CryptoBureau01/logo/main/logo.sh | bash
sleep 5

# Function to print info messages
print_info() {
    echo -e "\e[32m[INFO] $1\e[0m"
}

# Function to print error messages
print_error() {
    echo -e "\e[31m[ERROR] $1\e[0m"
}



#Function to check system type and root privileges
master_fun() {
    echo "Checking system requirements..."

    # Check if the system is Ubuntu
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            echo "This script is designed for Ubuntu. Exiting."
            exit 1
        fi
    else
        echo "Cannot detect operating system. Exiting."
        exit 1
    fi

    # Check if the user is root
    if [ "$EUID" -ne 0 ]; then
        echo "You are not running as root. Please enter root password to proceed."
        sudo -k  # Force the user to enter password
        if sudo true; then
            echo "Switched to root user."
        else
            echo "Failed to gain root privileges. Exiting."
            exit 1
        fi
    else
        echo "You are running as root."
    fi

    echo "System check passed. Proceeding to package installation..."
}



# Function to install dependencies
install_dependency() {
    print_info "<=========== Install Dependency ==============>"
    print_info "Updating and upgrading system packages, and installing required tools..."
    
    sudo apt update && sudo apt upgrade -y && sudo apt install git wget curl -y 

    # Install Node.js
    print_info "Installing Node.js..."
    wget https://raw.githubusercontent.com/CryptoBureau01/packages/main/node.sh && chmod +x node.sh && ./node.sh
    
    # Check if Node installation was successful
    if [ $? -ne 0 ]; then
        print_error "Failed to install Node.js. Please check your system."
        exit 1
    fi

    # Remove node.sh only if installation was successful
    rm -f node.sh

    # Check Node.js & npm version
    print_info "Checking Node.js and npm version..."
    node -v && npm -v

    # Install Hardhat
    print_info "Installing Hardhat..."
    npm install -g hardhat

    # Call the next function (Ensure 'master' exists)
    if command -v master &> /dev/null; then
        master
    else
        print_error "'master' function not found. Skipping..."
    fi
}


contract-setup() {
    REPO_URL="https://github.com/CryptoBureau01/evm-nft-contract.git"
    FOLDER_NAME="evm-nft-contract"

    if [ -d "$FOLDER_NAME" ]; then
        echo "[WARNING] Folder '$FOLDER_NAME' already exists!"
        read -p "Do you want to keep the existing folder? (y/n): " choice

        if [[ "$choice" =~ ^[Nn]$ ]]; then
            echo "[INFO] Removing existing folder..."
            rm -rf "$FOLDER_NAME"
            echo "[INFO] Cloning fresh repository..."
            git clone "$REPO_URL"
        else
            echo "[INFO] Using existing folder..."
        fi
    else
        echo "[INFO] Cloning contract repository..."
        git clone "$REPO_URL"
    fi

    cd "$FOLDER_NAME" || { echo "[ERROR] Failed to enter directory"; exit 1; }

    echo "[INFO] Creating/Updating .env file..."

    # Prompt user for private key
    read -sp "Enter your private key: " PRIVATE_KEY
    echo ""

    # Ensure private key starts with 0x (auto-add if missing)
    if [[ $PRIVATE_KEY != 0x* ]]; then
        PRIVATE_KEY="0x$PRIVATE_KEY"
    fi

    # Save private key to .env file
    echo "PRIVATE_KEY=$PRIVATE_KEY" > .env
    echo "[INFO] Private key saved successfully."

    echo "[INFO] Installing dependencies..."
    npm install

    echo "[INFO] Contract setup completed successfully!"

    # Call master function at the end
    master
}


compile-contract() {
    CONTRACT_DIR="/root/evm-nft-contract"

    # Check if the contract folder exists
    if [ ! -d "$CONTRACT_DIR" ]; then
        echo "[ERROR] Contract folder '$CONTRACT_DIR' not found! Please run contract-setup first."
        exit 1
    fi

    # Enter the contract folder
    cd "$CONTRACT_DIR" || { echo "[ERROR] Failed to enter contract directory"; exit 1; }

    echo "[INFO] Compiling the contract..."
    npx hardhat compile

    echo "[INFO] Compilation completed successfully!"

    # Call master function at the end
    master
}


deploy-contract() {
    CONTRACT_DIR="/root/evm-nft-contract"
    ENV_FILE="$CONTRACT_DIR/.envUser"

    # Check if the contract folder exists
    if [ ! -d "$CONTRACT_DIR" ]; then
        echo "[ERROR] Contract folder '$CONTRACT_DIR' not found! Please run contract-setup first."
        exit 1
    fi

    # Enter the contract directory
    cd "$CONTRACT_DIR" || { echo "[ERROR] Failed to enter contract directory"; exit 1; }

    echo "[INFO] Deploying the contract..."
    npx hardhat run scripts/deploy.js --network monadTestnet

    # Check if .envUser exists after deployment
    if [ ! -f "$ENV_FILE" ]; then
        echo "[ERROR] .envUser file not found! Deployment might have failed."
        exit 1
    fi

    # Load CONTRACT_ADDRESS from .envUser
    unset CONTRACT_ADDRESS
    set -a
    source "$ENV_FILE"
    set +a

    # Verify CONTRACT_ADDRESS was set and print it
    if [[ -n "$CONTRACT_ADDRESS" && "$CONTRACT_ADDRESS" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo "[SUCCESS] Contract deployed successfully!"
        echo "[INFO] Contract Address: $CONTRACT_ADDRESS"
    else
        echo "[ERROR] CONTRACT_ADDRESS missing in .envUser! Check deployment."
        exit 1
    fi

    # Call master function at the end
    master
}




verify() {
    CONTRACT_DIR="/root/evm-nft-contract"
    ENV_FILE="$CONTRACT_DIR/.envUser"
    ENV_MAIN_FILE="$CONTRACT_DIR/.env"

    # Check if required files exist
    if [ ! -d "$CONTRACT_DIR" ]; then
        echo "[ERROR] Contract folder not found!"
        exit 1
    fi
    if [ ! -f "$ENV_FILE" ] || [ ! -f "$ENV_MAIN_FILE" ]; then
        echo "[ERROR] Required environment files (.envUser, .env) not found!"
        exit 1
    fi

    # Load environment variables
    unset CONTRACT_ADDRESS PRIVATE_KEY
    set -a
    source "$ENV_FILE"
    source "$ENV_MAIN_FILE"
    set +a

    # Validate environment variables
    if [ -z "$CONTRACT_ADDRESS" ] || [ -z "$PRIVATE_KEY" ]; then
        echo "[ERROR] Missing CONTRACT_ADDRESS or PRIVATE_KEY!"
        exit 1
    fi

    # Check format correctness
    if [[ ! $PRIVATE_KEY =~ ^0x[a-fA-F0-9]{64}$ ]] || [[ ! $CONTRACT_ADDRESS =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo "[ERROR] Invalid PRIVATE_KEY or CONTRACT_ADDRESS format!"
        exit 1
    fi

    # Navigate to contract directory
    cd "$CONTRACT_DIR" || { echo "[ERROR] Failed to enter contract directory"; exit 1; }

    # Run Hardhat verify command
    echo "[INFO] Verifying contract on MonadTestnet..."
    if npx hardhat verify --network monadTestnet "$CONTRACT_ADDRESS"; then
        echo "[SUCCESS] Contract verification completed!"
    else
        echo "[ERROR] Contract verification failed!"
        exit 1
    fi

    # Call master function at the end
    master
}




mint-nft() {
    CONTRACT_DIR="/root/evm-nft-contract"  # Update path if needed
    ENV_FILE="$CONTRACT_DIR/.envUser"

    # Check if contract folder exists
    if [ ! -d "$CONTRACT_DIR" ]; then
        echo "[ERROR] Contract folder not found!"
        exit 1
    fi

    # Check if .envUser file exists
    if [ ! -f "$ENV_FILE" ]; then
        echo "[ERROR] .envUser file not found!"
        exit 1
    fi

    # Load environment variables
    unset CONTRACT_ADDRESS
    set -a
    source "$ENV_FILE"
    set +a

    # Validate CONTRACT_ADDRESS
    if [ -z "$CONTRACT_ADDRESS" ]; then
        echo "[ERROR] CONTRACT_ADDRESS not set!"
        exit 1
    fi

    echo "[INFO] Checking CONTRACT_ADDRESS in .envUser..."
    echo "[INFO] CONTRACT_ADDRESS found: $CONTRACT_ADDRESS"

    # Ask for Private Key
    read -s -p "Enter your private key: " PRIVATE_KEY
    echo ""
    export PRIVATE_KEY  # Set as environment variable

    # Ensure private key starts with 0x (auto-add if missing)
    if [[ $PRIVATE_KEY != 0x* ]]; then
        PRIVATE_KEY="0x$PRIVATE_KEY"
    fi

    echo "[INFO] PRIVATE_KEY saved successfully."

    # Ask for number of NFTs to mint
    read -p "Enter the number of NFTs to mint: " NUM_NFTS
    if ! [[ "$NUM_NFTS" =~ ^[0-9]+$ ]]; then
        echo "[ERROR] Invalid number!"
        exit 1
    fi

    echo "[INFO] Minting $NUM_NFTS NFT(s)..."

    # **Navigate to Hardhat project folder before running commands**
    cd "$CONTRACT_DIR" || { echo "[ERROR] Failed to enter contract directory"; exit 1; }

    # Run Hardhat mint command
    if npx hardhat run scripts/mint.js --network monadTestnet "$NUM_NFTS"; then
        echo "[SUCCESS] Minting successful!"
    else
        echo "[ERROR] Minting failed! Check Hardhat logs for details."
        exit 1
    fi

    # Call master function at the end
    master
}








# Function to display menu and prompt user for input
master() {
    print_info "==============================="
    print_info "    EVM Contract Tool Menu     "
    print_info "==============================="
    print_info ""
    print_info "1. Install-Dependency"
    print_info "2. Contract-Setup"
    print_info "3. Compile-Contract"
    print_info "4. Deploy-Contract"
    print_info "5. Verify-Contract"
    print_info ""
    print_info "!=============================!"
    print_info ""
    print_info "6. Mint-NFT"
    print_info "7. Exit"
    print_info ""
    print_info "==============================="
    print_info " Created By : CB-Master "
    print_info "==============================="
    print_info ""
    
    read -p "Enter your choice (1 or 7): " user_choice

    case $user_choice in
        1)
            install_dependency
            ;;
        2)
            contract-setup
            ;;
        3) 
            compile-contract
            ;;
        4)
            deploy-contract
            ;;
        5)
            verify
            ;;
        6)
            mint-nft
            ;;
        7)
            exit 0  # Exit the script after breaking the loop
            ;;
        *)
            print_error "Invalid choice. Please enter 1 or 7 : "
            ;;
    esac
}

# Call the uni_menu function to display the menu
master_fun
master
