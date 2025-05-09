# Complete Deployment Guide for Milestone 1

This guide provides step-by-step instructions for deploying Milestone 1 of the Azure Function App with secure configuration.

## Prerequisites

1. **Install required tools**:
    - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
    - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

2. **Log in to Azure**:
   ```bash
   az login
   ```

3. **Check your subscription**:
   ```bash
   az account show
   ```
   If you have multiple subscriptions, set the one you want to use:
   ```bash
   az account set --subscription "your-subscription-id"
   ```

## Step 1: Clean Up Existing Resources (Optional)

If you need to clean up existing resources, use the provided cleanup script:

```bash
# Make the script executable
chmod +x cleanup.sh

# Run the script
./cleanup.sh
```

The script will prompt you before deleting resources.

## Step 2: Set Up Terraform Backend

1. Make the backend setup script executable:
   ```bash
   chmod +x setup-backend.sh
   ```

2. Run the script to create the backend resources:
   ```bash
   ./setup-backend.sh
   ```

   This will create:
    - A resource group for Terraform state
    - A storage account with a unique name
    - A blob container for state files
    - A backend.conf file with the configuration

## Step 3: Initialize Terraform with Backend

```bash
terraform init -backend-config=backend.conf
```

## Step 4: Deploy the Infrastructure

1. **Plan the deployment**:
   ```bash
   terraform plan -out=tfplan
   ```

2. **Apply the configuration**:
   ```bash
   terraform apply tfplan
   ```

## Step 5: Deploy the Test Function (Optional)

After the infrastructure is deployed, you can deploy the sample function to test Key Vault integration:

```bash
# Navigate to the Azure Portal
# Go to your function app (name is in the outputs)
# Under "Functions" click "Create" to create a new function
# Select "HTTP trigger"
# Name it "ApiTest"
# Copy the content from function/run.ps1 and function/function.json files
```

Alternatively, you can use Azure CLI to deploy the function:

```bash
# Create a ZIP file with the function
cd function
zip -r ../function.zip .
cd ..

# Deploy the function
az functionapp deployment source config-zip \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw function_app_name) \
  --src function.zip
```

## Step 6: Test the Function App

1. Get the function URL from the Azure Portal or using the following command:
   ```bash
   az functionapp function show \
     --resource-group $(terraform output -raw resource_group_name) \
     --name $(terraform output -raw function_app_name) \
     --function-name ApiTest \
     --query "invokeUrlTemplate" \
     --output tsv
   ```

2. Add your function key to the URL (you can get this from the Azure Portal)

3. Access the URL in a browser or use curl:
   ```bash
   curl "https://your-function-url"
   ```

## Troubleshooting

### Common Issues

1. **Key Vault Access Denied**:
    - Make sure the function app's managed identity has the correct permissions
    - Check that you are properly authenticated with sufficient Azure permissions
    - Ensure the time_sleep resources are sufficient for access policy propagation

2. **Terraform State Lock Issues**:
   If a state lock persists after an error:
   ```bash
   terraform force-unlock LOCK_ID
   ```

3. **Terraform Provider Version Issues**:
   If you get provider version errors:
   ```bash
   terraform init -upgrade
   ```

### Checking Key Vault Access

To verify that your function app has access to Key Vault:

```bash
# Get the principal ID of your function app
PRINCIPAL_ID=$(az functionapp identity show \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw function_app_name) \
  --query principalId -o tsv)

# Check access policies on the Key Vault
az keyvault show \
  --name $(terraform output -raw key_vault_name) \
  --query "properties.accessPolicies[?objectId=='$PRINCIPAL_ID']"
```

## Next Steps

After successfully deploying Milestone 1, you can proceed to Milestone 2, which involves setting up monitoring resources.