# Ensure Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI is not installed. Please install it to proceed."
    exit
}

# Login to Azure using Azure CLI
az login

# Function to find the subnet associated with the private IP address
function Find-SubnetForIP {
    param (
        [string]$privateIpAddress
    )
    
    Write-Host "Searching for the subnet containing the IP Address: $privateIpAddress"

    # Get all the subnets and check each one for the IP address
    $subnets = az network vnet subnet list --query "[].{Name: name, AddressPrefix: addressPrefix, VnetName: virtualNetworkName, ResourceGroup: resourceGroup}" --output json | ConvertFrom-Json

    $foundSubnet = $null
    foreach ($subnet in $subnets) {
        # Check if the private IP is within the subnet's address range
        if ($privateIpAddress -match $subnet.AddressPrefix) {
            $foundSubnet = $subnet
            break
        }
    }

    return $foundSubnet
}

# Function to find the NIC using the private IP
function Find-NicUsingIP {
    param (
        [string]$privateIpAddress
    )
    
    Write-Host "Searching for a NIC that is using the IP Address: $privateIpAddress"
    
    # List all network interfaces and check if any NIC has the IP address assigned
    $nics = az network nic list --query "[].{Name: name, IPConfigs: ipConfigurations}" --output json | ConvertFrom-Json
    $foundNic = $null

    foreach ($nic in $nics) {
        foreach ($ipConfig in $nic.IPConfigs) {
            if ($ipConfig.privateIpAddress -eq $privateIpAddress) {
                $foundNic = $nic
                break
            }
        }

        if ($foundNic) {
            break
        }
    }

    return $foundNic
}

# Prompt the user for the private IP address
$privateIpAddress = Read-Host "Enter the Private IP Address to search for"

# Validate the IP address format (basic validation)
if ($privateIpAddress -match "^\d{1,3}(\.\d{1,3}){3}$") {
    # Find the subnet for the IP Address
    $subnet = Find-SubnetForIP -privateIpAddress $privateIpAddress

    if ($subnet) {
        Write-Host "Found subnet: $($subnet.Name) in VNet: $($subnet.VnetName) under Resource Group: $($subnet.ResourceGroup)"
    } else {
        Write-Host "No subnet found containing the IP Address: $privateIpAddress"
    }

    # Find if there is a NIC using this private IP
    $nic = Find-NicUsingIP -privateIpAddress $privateIpAddress

    if ($nic) {
        Write-Host "Found Network Interface Card (NIC) using the IP Address:"
        Write-Host "NIC Name: $($nic.Name)"
        
        # Retrieve the resource that the NIC is associated with
        $resource = az resource show --ids "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$($subnet.ResourceGroup)/providers/Microsoft.Network/networkInterfaces/$($nic.Name)" --query "{Resource: name, ResourceType: type}" --output json | ConvertFrom-Json
        Write-Host "Associated Resource: $($resource.Resource), Type: $($resource.ResourceType)"
    } else {
        Write-Host "No NIC found using the IP Address: $privateIpAddress"
    }
} else {
    Write-Host "The IP address format is invalid. Please provide a valid private IP address."
}
