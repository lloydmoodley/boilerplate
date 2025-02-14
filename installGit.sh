#!/bin/bash

# Function to check if Git is installed
check_git_installed() {
    if command -v git &> /dev/null; then
        echo "Git is already installed."
        echo "Installed version: $(git --version)"
        exit 0
    else
        echo "Git is not installed. Proceeding with installation."
    fi
}

# Function to install Git
install_git() {
    echo "Updating package list..."
    sudo apt update

    echo "Installing Git..."
    sudo apt install -y git

    if command -v git &> /dev/null; then
        echo "Git has been successfully installed."
        echo "Installed version: $(git --version)"
    else
        echo "Failed to install Git. Please check your system settings."
        exit 1
    fi
}

# Main script logic
check_git_installed
install_git
