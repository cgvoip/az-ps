# Ensure the Az module is installed
Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser

# Import Azure module
Import-Module Az

# Login to Azure account
Connect-AzAccount

# Function to create a policy exemption
function Create-PolicyExemption {
    param (
        [string]$Scope,
        [string]$PolicyDefinitionName,
        [string]$ExemptionReason,
        [datetime]$ExpiryDate
    )

    try {
        # Create policy exemption
        $exemption = New-AzPolicyExemption -Scope $Scope -PolicyDefinitionName $PolicyDefinitionName -Reason $ExemptionReason -ExpiresOn $ExpiryDate

        Write-Host "Policy Exemption created successfully!"
        Write-Host "Exemption ID: $($exemption.Id)"
        Write-Host "Policy Name: $($exemption.PolicyDefinitionName)"
        Write-Host "Scope: $Scope"
        Write-Host "Exemption Reason: $ExemptionReason"
        Write-Host "Expires On: $ExpiryDate"
    }
    catch {
        Write-Host "An error occurred: $_"
    }
}

# Prompt the user for inputs
Write-Host "Create Azure Policy Exemption"

# Get the scope of the exemption
$validScopes = @("Subscription", "ResourceGroup", "Resource")
$selectedScope = Read-Host "Select the scope of the exemption (Subscription/ResourceGroup/Resource)"
if ($validScopes -notcontains $selectedScope) {
    Write-Host "Invalid scope selected. Please select from: Subscription, ResourceGroup, or Resource"
    exit
}

# Prompt for the necessary inputs based on the scope
$subscriptionId = Read-Host "Enter the Subscription ID"

if ($selectedScope -eq "ResourceGroup") {
    $resourceGroupName = Read-Host "Enter the Resource Group Name"
    $scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName"
}
elseif ($selectedScope -eq "Resource") {
    $resourceGroupName = Read-Host "Enter the Resource Group Name"
    $resourceName = Read-Host "Enter the Resource Name"
    $resourceType = Read-Host "Enter the Resource Type"
    $scope = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/$resourceType/$resourceName"
}
else {
    $scope = "/subscriptions/$subscriptionId"
}

# Prompt for policy definition name
$policyDefinitionName = Read-Host "Enter the Policy Definition Name"

# Prompt for the reason for exemption
$exemptionReason = Read-Host "Enter the reason for the exemption"

# Prompt for the expiration date of the exemption
$expiryDateString = Read-Host "Enter the expiry date of the exemption (yyyy-MM-dd)"
$expiryDate = [datetime]::ParseExact($expiryDateString, "yyyy-MM-dd", $null)

# Create the policy exemption
Create-PolicyExemption -Scope $scope -PolicyDefinitionName $policyDefinitionName -ExemptionReason $exemptionReason -ExpiryDate $expiryDate
