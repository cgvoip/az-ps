# Ensure that the user is logged into Azure
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI is not installed. Please install it to proceed."
    exit
}

# Login to Azure account using Azure CLI
az login

# Prompt user for subscription, resource group, and service name
$subscriptionId = Read-Host "Enter the Subscription ID"
$resourceGroupName = Read-Host "Enter the Resource Group Name"
$serviceName = Read-Host "Enter the name of the Azure service"

# Set the active subscription
az account set --subscription $subscriptionId

# Fetch information about the specified Azure service
Write-Host "Retrieving information for service '$serviceName' in resource group '$resourceGroupName'..."

# Fetch resource details using the Azure CLI
$resourceDetails = az resource show --resource-group $resourceGroupName --name $serviceName --query "*" --output json

# Check if service exists
if ($resourceDetails -eq $null) {
    Write-Host "No information found for service '$serviceName' in resource group '$resourceGroupName'. Please verify the inputs."
    exit
}

# Convert the JSON response to a PowerShell object and display
$resourceDetailsObj = $resourceDetails | ConvertFrom-Json

# Display all available details
Write-Host "Service Details:"
$resourceDetailsObj | Format-List
