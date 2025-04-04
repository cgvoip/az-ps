# Ensure that the user is logged into Azure
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI is not installed. Please install it to proceed."
    exit
}

# Login to Azure account using Azure CLI
az login

# Function to deploy an Azure Virtual Machine
function Deploy-AzureVM {
    param (
        [string]$vmName,
        [string]$resourceGroup,
        [string]$location,
        [string]$vmSize,
        [string]$image,
        [string]$adminUsername,
        [string]$adminPassword
    )

    Write-Host "Creating Virtual Machine: $vmName in Resource Group: $resourceGroup"

    # Create the virtual machine using Azure CLI
    az vm create `
        --name $vmName `
        --resource-group $resourceGroup `
        --location $location `
        --size $vmSize `
        --image $image `
        --admin-username $adminUsername `
        --admin-password $adminPassword `
        --authentication-type password

    Write-Host "VM $vmName created successfully!"
}

# Function to deploy a Gateway Packet Capture
function Deploy-GatewayPacketCapture {
    param (
        [string]$resourceGroup,
        [string]$location,
        [string]$captureName,
        [string]$gatewayId,
        [string]$packetCaptureDirectory
    )

    Write-Host "Deploying Gateway Packet Capture: $captureName on Gateway: $gatewayId"

    # Create the packet capture resource
    az network watcher packet-capture create `
        --resource-group $resourceGroup `
        --location $location `
        --name $captureName `
        --target $gatewayId `
        --storage-account $packetCaptureDirectory `
        --capture-criteria "Any" # Adjust this as needed for more specific criteria

    Write-Host "Packet capture $captureName deployed successfully!"
}

# Main script

# Ask user for the task they want to perform
$taskChoice = Read-Host "Would you like to create an Azure VM or deploy a Gateway Packet Capture? (vm/packetCapture)"

if ($taskChoice -eq "vm") {
    # Ask for values to create a VM
    $vmName = Read-Host "Enter the name of the virtual machine"
    $resourceGroup = Read-Host "Enter the resource group name"
    $location = Read-Host "Enter the location (e.g., eastus)"
    $vmSize = Read-Host "Enter the VM size (e.g., Standard_B2s)"
    $image = Read-Host "Enter the VM image (e.g., UbuntuLTS)"
    $adminUsername = Read-Host "Enter the admin username"
    $adminPassword = Read-Host "Enter the admin password" -AsSecureString

    # Deploy the VM
    Deploy-AzureVM -vmName $vmName -resourceGroup $resourceGroup -location $location -vmSize $vmSize -image $image -adminUsername $adminUsername -adminPassword $adminPassword
}
elseif ($taskChoice -eq "packetCapture") {
    # Ask for values to create a Packet Capture
    $resourceGroup = Read-Host "Enter the resource group name"
    $location = Read-Host "Enter the location (e.g., eastus)"
    $captureName = Read-Host "Enter the packet capture name"
    $gatewayId = Read-Host "Enter the Gateway ID"
    $packetCaptureDirectory = Read-Host "Enter the storage account directory where the capture will be stored"

    # Deploy the packet capture
    Deploy-GatewayPacketCapture -resourceGroup $resourceGroup -location $location -captureName $captureName -gatewayId $gatewayId -packetCaptureDirectory $packetCaptureDirectory
}
else {
    Write-Host "Invalid choice. Please select either 'vm' or 'packetCapture'."
}
