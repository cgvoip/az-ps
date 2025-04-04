# Ensure the Azure CLI is installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI is not installed. Please install it to proceed."
    exit
}

# Login to Azure account using Azure CLI
az login

# Function to get parameters from the policy definition
function Get-PolicyParameters {
    param (
        [string]$PolicyDefinitionId
    )
    
    # Fetch the policy definition and extract parameters
    $policyDefinition = az policy definition show --id $PolicyDefinitionId | ConvertFrom-Json

    # Check if parameters exist in the policy
    if ($policyDefinition.parameters) {
        $parameters = $policyDefinition.parameters
        return $parameters
    } else {
        Write-Host "No parameters found for this policy."
        return $null
    }
}

# Prompt user for Policy Definition ID
$policyDefinitionId = Read-Host "Enter the Policy Definition ID"

# Get the policy parameters
$parameters = Get-PolicyParameters -PolicyDefinitionId $policyDefinitionId

# If parameters are found, ask the user for values
if ($parameters) {
    $parameterValues = @{}
    
    # Iterate over each parameter and prompt for a value
    foreach ($param in $parameters.PSObject.Properties) {
        $paramName = $param.Name
        $paramType = $param.Value.type
        $paramDescription = $param.Value.metadata.description
        $defaultValue = $param.Value.defaultValue

        $prompt = "$paramDescription (default: $defaultValue)"
        $paramValue = Read-Host "$paramName - $prompt"

        if (-not $paramValue) {
            $paramValue = $defaultValue
        }

        $parameterValues[$paramName] = $paramValue
    }

    Write-Host "Parameters successfully collected."
}

# Ask user where the policy will be assigned
$assignmentScope = Read-Host "Where would you like to assign the policy? (resourceGroup/subscription/managementGroup)"

# Based on the user's choice, prompt for scope-specific values
switch ($assignmentScope.ToLower()) {
    "resourcegroup" {
        $resourceGroupName = Read-Host "Enter the Resource Group Name"
        $scope = "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$resourceGroupName"
        break
    }
    "subscription" {
        $scope = "/subscriptions/$(az account show --query id -o tsv)"
        break
    }
    "managementgroup" {
        $managementGroupId = Read-Host "Enter the Management Group ID"
        $scope = "/providers/Microsoft.Management/managementGroups/$managementGroupId"
        break
    }
    default {
        Write-Host "Invalid scope selected. Please choose resourceGroup, subscription, or managementGroup."
        exit
    }
}

# Prepare the parameters for the policy assignment
$assignmentParameters = $parameterValues | ConvertTo-Json -Depth 5

# Assign the policy to the chosen scope
Write-Host "Assigning policy to $scope..."

# Deploy and assign the policy using Azure CLI
$policyAssignmentId = Read-Host "Enter a unique Policy Assignment ID"
az policy assignment create --policy $policyDefinitionId --assign-identity --scope $scope --parameters "$assignmentParameters" --name $policyAssignmentId

Write-Host "Policy assigned successfully to $scope"
