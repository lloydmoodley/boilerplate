#!/bin/bash

# Function to check if .NET is installed
check_dotnet_installed() {
    if command -v dotnet &> /dev/null; then
        echo ".NET is already installed."
        echo "Installed version: $(dotnet --version)"
        exit 0
    else
        echo ".NET is not installed. Proceeding with installation."
    fi
}

# Function to install .NET SDK
install_dotnet() {
    # Add Microsoft package repository if not already added
    echo "Adding Microsoft package repository..."
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb

    # Update package lists
    echo "Updating package lists..."
    sudo apt update

    # Install .NET SDK 8.0
    echo "Installing .NET SDK 8.0..."
    sudo apt install -y dotnet-sdk-8.0

    if command -v dotnet &> /dev/null; then
        echo ".NET has been successfully installed."
        echo "Installed version: $(dotnet --version)"
    else
        echo "Failed to install .NET. Please check your system settings."
        exit 1
    fi
}

# Main script logic
check_dotnet_installed
install_dotnet
