#!/bin/bash
# Check if a parameter was provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <project_name> <git.username> <git.email> <git.initial.branch>"
    exit 1
fi

echo ""

#!/bin/bash

# Function to check if .NET is installed
check_dotnet_installed() {
    if command -v dotnet &> /dev/null; then
        echo ".NET is already installed."
        echo "Installed version: $(dotnet --version)"
    else
        echo ".NET is not installed. Proceeding with installation."
        install_dotnet
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
    fi
}

# Function to check if Git is installed
check_git_installed() {
    if command -v git &> /dev/null; then
        echo "Git is already installed."
        echo "Installed version: $(git --version)"
    else
        echo "Git is not installed. Proceeding with installation."
        install_git
    fi
}

# Function to install Git
install_git() {
    echo "Updating package list..."
    sudo apt update

    echo "Installing Git..."
    sudo apt install -y git
        
    echo "setting user email $gitUserEmail"
    git config --global user.email $gitUserEmail
    echo "setting user name $gitUserName"
    git config --global user.name $gitUserName
    echo "setting user name $gitInitialBranch"
    git config --global $gitInitialBranch

    if command -v git &> /dev/null; then
        echo "Git has been successfully installed."
        echo "Installed version: $(git --version)"
    else
        echo "Failed to install Git. Please check your system settings."        
    fi
}

echo_green() {
   echo -e "\e[32m$1\e[0m"
}

# Setup variables
echo_green "Setting up variables"
solutionName="$1"
databaseName="$1.Database"
modelName="$1.Models"
repositoryName="$1.Repository"
serviceName="$1.Service"
apiName="$1.Api"
mvcName="$1.Mvc"
gitUserEmail="$2"
gitUserName="$3"
gitInitialBranch="$4"

# Main script logic
check_dotnet_installed
check_git_installed

# Create the solution folder
echo_green "Creating the solution folder"
mkdir -p "$solutionName"
cd $solutionName

# Create git repository
echo_green "Create git repository"
dotnet new gitignore
git init --initial-branch=gitInitialBranch

# Create the project folders
echo_green "Create the project folders"

mkdir -p -v "$databaseName"
mkdir -p -v "$modelName"
mkdir -p -v "$repositoryName"
mkdir -p -v "$serviceName"
mkdir -p -v "$apiName"
mkdir -p -v "$mvcName"

echo_green "Create the solution"
dotnet new sln

echo_green "Create the project for Models"
dotnet new classlib -lang C# -o $databaseName

echo_green "Create the project for Models"
dotnet new classlib -lang C# -o $modelName

echo_green "Create the project for the Repository"
dotnet new classlib -lang C# -o $repositoryName

echo_green "Create the project for the Service"
dotnet new classlib -lang C# -o $serviceName

echo_green "Create the project for the Api"
dotnet new classlib -lang C# -o $apiName

echo_green "Create the project for the Mvc.Ui"
dotnet new mvc -lang C# -o $mvcName
dotnet user-secrets init --project $mvcName
dotnet user-secrets set "ConnectionStrings:localdb" "Server=localhost;Database=$1;User Id=myUsername;Password=myPassword;" --project $mvcName

echo_green "Create build supporting files"
dotnet new buildprops
dotnet new buildtargets

dotnet sln add "./$databaseName/$databaseName.csproj"
dotnet sln add "./$modelName/$modelName.csproj"
dotnet sln add "./$repositoryName/$repositoryName.csproj"
dotnet sln add "./$serviceName/$serviceName.csproj"
dotnet sln add "./$apiName/$apiName.csproj"
dotnet sln add "./$mvcName/$mvcName.csproj"
dotnet build

git add .
git commit -m "Initialize projects with Model, Repository and MVC UI"

echo_green "Adding Entity Framework Core to the repository project"
cd ./$repositoryName/
dotnet add package Microsoft.EntityFrameworkCore
#dotnet add package Microsoft.EntityFrameworkCore.SqlServer   # For SQL Server
dotnet add package Pomelo.EntityFrameworkCore.MySql           # For MySQL
dotnet restore
cd ..

git add .
git commit -m "Add EF to the database project"

echo_green "Update Repository Project. Add a reference to the Models Project"
cd $repositoryName
dotnet add reference "../$modelName/$modelName.csproj"
dotnet restore
cd ..
git add .
git commit -m "Update Repository Project. Add a reference to the Models Project"

echo_green "Project '$solutionName' created successfully."

