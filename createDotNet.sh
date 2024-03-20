#!/bin/bash
# Check if a parameter was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

echo ""
echo "Ensure you have .NET Core 8 installed."
echo "Ensure you have Git Installed"
echo "  git config --global user.email 'you@example.com'"
echo "  git config --global user.name 'Your Name''"



# Setup variables
echo "Setting up variables"
solutionName="$1"
modelName="$1.Models"
repositoryName="$1.Repository"
mvcName="$1.Mvc"

# Create the solution folder
echo "Creating the solution folder"
mkdir -p "$solutionName"
cd $solutionName

# Create git repository
echo "Create git repository"
dotnet new gitignore
git init

# Create the project folders
echo "Create the project folders"

mkdir -p -v "$modelName"
mkdir -p -v "$repositoryName"
mkdir -p -v "$mvcName"

echo "Create the solution"
dotnet new sln

echo "Create the project for Models"
dotnet new classlib -lang C# -o $modelName

echo "Create the project for the Repository"
dotnet new classlib -lang C# -o $repositoryName

echo "Create the project for the Mvc.Ui"
dotnet new mvc -lang C# -o $mvcName
dotnet user-secrets init --project $mvcName
dotnet user-secrets set "ConnectionStrings:localdb" "Server=localhost;Database=$1;User Id=myUsername;Password=myPassword;" --project $mvcName

echo "Create build supporting files"
dotnet new buildprops
dotnet new buildtargets

dotnet sln add "./$modelName/$modelName.csproj"
dotnet sln add "./$repositoryName/$repositoryName.csproj"
dotnet sln add "./$mvcName/$mvcName.csproj"
dotnet build

git add .
git commit -m "Initialize projects with Model, Repository and MVC UI"

echo "Project '$solutionName' created successfully."
