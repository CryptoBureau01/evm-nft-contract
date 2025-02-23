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
    echo "[INFO] Cloning contract repository..."
    git clone https://github.com/CryptoBureau01/evm-nft-contract.git

    cd evm-nft-contract || { echo "[ERROR] Failed to enter directory"; exit 1; }

    echo "[INFO] Creating .env file..."

    # Prompt user for private key
    read -sp "Enter your private key (starting with 0x): " PRIVATE_KEY
    echo ""

    # Validate private key format
    if [[ ! $PRIVATE_KEY =~ ^0x[a-fA-F0-9]{64}$ ]]; then
        echo "[ERROR] Invalid private key format!"
        exit 1
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
    print_info "5. Verfiy-Contract"
    print_info "6. "
    print_info "7. "
    print_info "8. "
    print_info "9. "
    
    print_info ""
    print_info "==============================="
    print_info " Created By : CB-Master "
    print_info "==============================="
    print_info ""
    
    read -p "Enter your choice (1 or 3): " user_choice

    case $user_choice in
        1)
            install_dependency
            ;;
        2)
            contract-setup
            ;;
        3) 

            ;;
        4)

            ;;
        5)

            ;;
        6)

            ;;
        7)

            ;;
        8)
            exit 0  # Exit the script after breaking the loop
            ;;
        *)
            print_error "Invalid choice. Please enter 1 or 3 : "
            ;;
    esac
}

# Call the uni_menu function to display the menu
master_fun
master
