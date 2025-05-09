# Milestone 1: Secure Function App Deployment

## Overview
Milestone 1 successfully implements a secure Azure Function App deployment with Key Vault integration. The solution follows infrastructure-as-code best practices using Terraform to automate the deployment of all required resources and configurations.

## Implemented Resources
The infrastructure deployed in Milestone 1 includes:

- **Resource Group** - A dedicated resource group in West Europe that contains all resources for the secure function app solution
- **Storage Account** - For hosting the function app's data and backend files
- **App Service Plan** - A consumption-based (Y1) plan to host the function app
- **Function App** - A Windows-based function app with PowerShell runtime
- **Key Vault** - For securely storing sensitive configuration values
- **Key Vault Secret** - The API-KEY secret with a predefined value

## Security Features
Several security best practices have been implemented:

- **Managed Identity** - The Function App uses a system-assigned managed identity for passwordless authentication to Key Vault
- **Secure Secret Management** - API keys are stored in Key Vault rather than directly in application settings
- **TLS Enforcement** - Minimum TLS 1.2 is enforced on all resources
- **HTTPS Only** - The Function App only accepts HTTPS connections (FTPS disabled)
- **Key Vault Access Policies** - Proper access policies are configured for both Terraform and the Function App's managed identity
- **Resource Naming Conventions** - Consistent naming with unique suffixes is applied to all resources

## Implementation Details
The Terraform implementation handles several complex scenarios:

- **Access Policy Propagation** - Uses time_sleep resources to ensure access policies have time to propagate
- **Dependency Management** - Establishes proper resource dependencies to prevent race conditions
- **App Settings Configuration** - Uses null_resource with Azure CLI to update the Function App settings with Key Vault references after all policies are in place
- **Function Code** - Provisions a basic HTTP trigger function to validate the Key Vault integration

## Deployment Process
The deployment follows these key steps:

- Backend configuration for Terraform state storage
- Resource group creation
- Storage account and App Service Plan deployment
- Function App creation with managed identity
- Key Vault creation and access policy configuration
- Secret creation and Function App configuration to use the Key Vault reference

## Outputs
After successful deployment, the following outputs are provided:

- **Resource Group Name** - The name of the created resource group
- **Function App Name** - The unique name of the deployed function app
- **Function App Hostname** - The hostname for accessing the function app
- **Function App URL** - The full URL for accessing the function API
- **Storage Account Name** - The name of the created storage account
- **Key Vault Name** - The name of the deployed key vault
- **Key Vault URI** - The URI endpoint for the key vault

## Testing the Deployment
To validate the deployment:

- Confirm all resources appear in the Azure Portal
- Check that the Function App has a system-assigned managed identity
- Verify that the Key Vault contains the API-KEY secret
- Confirm the Function App's application settings include a Key Vault reference for API_KEY
- Deploy and execute the HTTP trigger function to verify it can retrieve the secret from Key Vault

## Best Practices Applied
The implementation includes several best practices beyond the basic requirements:

- **Resource Tagging** - All resources are tagged for better organization and cost management
- **Parameter Validation** - Environment variable includes validation to prevent invalid values
- **Secure Defaults** - All resources use secure defaults where applicable
- **Consistent Naming** - Resources follow a consistent naming convention
- **Dependency Management** - Proper dependencies and wait times ensure successful deployment  
