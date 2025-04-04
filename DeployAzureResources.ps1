#Requires -RunAsAdministrator

# Ensure Azure CLI is installed and user is logged in
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI is not installed. Please install it from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit
}

# Check if logged into Azure
$account = az account show --output json 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "Not logged into Azure. Please log in."
    az login
    $account = az account show --output json | ConvertFrom-Json
}
Write-Host "Logged in as: $($account.user.name)" -ForegroundColor Green

# Function to display the menu and get user choice
function Show-Menu {
    Clear-Host
    Write-Host "=== Azure Resource Deployment Menu ===" -ForegroundColor Cyan
    Write-Host "1. Deploy Storage Account(s)"
    Write-Host "2. Deploy Virtual Machine(s)"
    Write-Host "3. Deploy Virtual Network(s)"
    Write-Host "4. Deploy Subnet(s)"
    Write-Host "5. Deploy Resource Group(s)"
    Write-Host "6. Exit"
    Write-Host "=====================================" -ForegroundColor Cyan
    $choice = Read-Host "Enter your choice (1-6)"
    return $choice
}

# Function to get resource count and resource group name
function Get-DeploymentDetails {
    param ($resourceType)
    $count = Read-Host "How many $resourceType(s) do you want to deploy? (e.g., 1, 2, 3)"
    while ($count -notmatch '^\d+$' -or [int]$count -lt 1) {
        Write-Host "Please enter a valid number greater than 0." -ForegroundColor Yellow
        $count = Read-Host "How many $resourceType(s) do you want to deploy?"
    }
    $rgName = Read-Host "Enter the resource group name for $resourceType deployment"
    return [PSCustomObject]@{
        Count = [int]$count
        ResourceGroup = $rgName
    }
}

# Function to deploy resources using Azure CLI
function Deploy-Resources {
    param ($choice)

    switch ($choice) {
        "1" { # Storage Account
            $details = Get-DeploymentDetails -resourceType "Storage Account"
            $location = "eastus" # Default location, can be parameterized
            for ($i = 1; $i -le $details.Count; $i++) {
                $storageName = "mystorage$((Get-Date).Ticks)$i" # Unique name
                Write-Host "Deploying Storage Account $i of $($details.Count): $storageName" -ForegroundColor Green
                az group create --name $details.ResourceGroup --location $location --output none
                az storage account create --name $storageName --resource-group $details.ResourceGroup --location $location --sku Standard_LRS --output none
                if ($?) {
                    Write-Host "Successfully deployed $storageName" -ForegroundColor Green
                } else {
                    Write-Host "Failed to deploy $storageName" -ForegroundColor Red
                }
            }
        }
        "2" { # Virtual Machine
            $details = Get-DeploymentDetails -resourceType "Virtual Machine"
            $location = "eastus"
            for ($i = 1; $i -le $details.Count; $i++) {
                $vmName = "myvm$i"
                Write-Host "Deploying Virtual Machine $i of $($details.Count): $vmName" -ForegroundColor Green
                az group create --name $details.ResourceGroup --location $location --output none
                az vm create --resource-group $details.ResourceGroup --name $vmName --image Win2019Datacenter --admin-username azureuser --admin-password "P@ssw0rd1234!" --location $location --size Standard_B1s --output none
                if ($?) {
                    Write-Host "Successfully deployed $vmName" -ForegroundColor Green
                } else {
                    Write-Host "Failed to deploy $vmName" -ForegroundColor Red
                }
            }
        }
        "3" { # Virtual Network
            $details = Get-DeploymentDetails -resourceType "Virtual Network"
            $location = "eastus"
            for ($i = 1; $i -le $details.Count; $i++) {
                $vnetName = "myvnet$i"
                Write-Host "Deploying Virtual Network $i of $($details.Count): $vnetName" -ForegroundColor Green
                az group create --name $details.ResourceGroup --location $location --output none
                az network vnet create --resource-group $details.ResourceGroup --name $vnetName --address-prefix 10.0.0.0/16 --location $location --output none
                if ($?) {
                    Write-Host "Successfully deployed $vnetName" -ForegroundColor Green
                } else {
                    Write-Host "Failed to deploy $vnetName" -ForegroundColor Red
                }
            }
        }
        "4" { # Subnet (requires a VNet)
            $details = Get-DeploymentDetails -resourceType "Subnet"
            $location = "eastus"
            $vnetName = Read-Host "Enter the Virtual Network name to add subnet(s) to"
            for ($i = 1; $i -le $details.Count; $i++) {
                $subnetName = "mysubnet$i"
                $addressPrefix = "10.0.$i.0/24"
                Write-Host "Deploying Subnet $i of $($details.Count): $subnetName in $vnetName" -ForegroundColor Green
                az group create --name $details.ResourceGroup --location $location --output none
                az network vnet subnet create --resource-group $details.ResourceGroup --vnet-name $vnetName --name $subnetName --address-prefixes $addressPrefix --output none
                if ($?) {
                    Write-Host "Successfully deployed $subnetName" -ForegroundColor Green
                } else {
                    Write-Host "Failed to deploy $subnetName" -ForegroundColor Red
                }
            }
        }
        "5" { # Resource Group
            $details = Get-DeploymentDetails -resourceType "Resource Group"
            $location = "eastus"
            for ($i = 1; $i -le $details.Count; $i++) {
                $rgName = "$($details.ResourceGroup)$i"
                Write-Host "Deploying Resource Group $i of $($details.Count): $rgName" -ForegroundColor Green
                az group create --name $rgName --location $location --output none
                if ($?) {
                    Write-Host "Successfully deployed $rgName" -ForegroundColor Green
                } else {
                    Write-Host "Failed to deploy $rgName" -ForegroundColor Red
                }
            }
        }
        "6" { # Exit
            Write-Host "Exiting script..." -ForegroundColor Yellow
            exit
        }
        default {
            Write-Host "Invalid choice. Please select 1-6." -ForegroundColor Red
        }
    }
}

# Main loop
do {
    $choice = Show-Menu
    Deploy-Resources -choice $choice
    if ($choice -ne "6") {
        Read-Host "Press Enter to return to the menu"
    }
} while ($choice -ne "6")
