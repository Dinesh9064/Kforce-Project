# Deployment Instructions

This document provides step-by-step instructions for deploying each milestone of the Azure Function App Secure Deployment project.

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (version 2.40.0 or later)
- [Terraform](https://www.terraform.io/downloads.html) (version 1.3.0 or later)
- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) (version 7.0 or later)
- Azure subscription with Contributor access
- Git for version control

## Initial Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/azure-function-secure-deployment.git
   cd azure-function-secure-deployment
   ```

2. Login to Azure:
   ```bash
   az login
   ```

3. Set your subscription:
   ```bash
   az account set --subscription "your-subscription-id"
   ```

4. Prepare Terraform backend storage:
   ```bash
   # Create a resource group for Terraform state
   az group create --name tfstate-rg --location westeurope
   
   # Create the storage account
   az storage account create --name tfstateq0m19cdw \
     --resource-group tfstate-rg \
     --location westeurope \
     --sku Standard_LRS \
     --kind StorageV2 \
     --encryption-services blob \
     --allow-blob-public-access false \
     --min-tls-version TLS1_2
   
   # Get the storage account key
   ACCOUNT_KEY=$(az storage account keys list --resource-group tfstate-rg --account-name tfstateq0m19cdw --query '[0].value' -o tsv)
   
   # Create a container for the Terraform state files
   az storage container create --name tfstate \
     --account-name tfstateq0m19cdw \
     --account-key $ACCOUNT_KEY
   
   # Create a backend.conf file for Terraform
   cat > backend.conf << EOF
   storage_account_name=tfstateq0m19cdw
   container_name=tfstate
   resource_group_name=tfstate-rg
   EOF
   
   echo "Terraform backend storage has been set up successfully."
   ```

## Milestone 1: Secure Function App Deployment with Key Vault Integration

1. Navigate to the Milestone 1 directory:
   ```bash
   cd milestone1/terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init -backend-config="storage_account_name=tfstateq0m19cdw" \
                 -backend-config="container_name=tfstate" \
                 -backend-config="key=milestone1.tfstate" \
                 -backend-config="resource_group_name=tfstate-rg"
   ```

3. Review the deployment plan:
   ```bash
   terraform plan -out=milestone1.tfplan -var="resource_group_name=milestones-we-dev" -var="location=westeurope" -var="suffix=n2cte9"
   ```

4. Apply the deployment:
   ```bash
   terraform apply "milestone1.tfplan"
   ```

5. Verify the deployment:
   ```bash
   # Verify Function App deployment
   az functionapp show --name secure-func-n2cte9 --resource-group milestones-we-dev

   # Verify Key Vault integration
   az keyvault show --name func-kv-n2cte9 --resource-group milestones-we-dev
   ```

## Milestone 2: Monitoring Configuration with Application Insights and Log Analytics

1. Navigate to the Milestone 2 directory:
   ```bash
   cd ../milestone2/terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init -backend-config="storage_account_name=tfstateq0m19cdw" \
                 -backend-config="container_name=tfstate" \
                 -backend-config="key=milestone2.tfstate" \
                 -backend-config="resource_group_name=tfstate-rg"
   ```

3. Review the deployment plan:
   ```bash
   terraform plan -out=milestone2.tfplan -var="resource_group_name=milestones-we-dev" -var="location=westeurope" -var="suffix=n2cte9"
   ```

4. Apply the deployment:
   ```bash
   terraform apply "milestone2.tfplan"
   ```

5. Verify the deployment:
   ```bash
   # Verify Application Insights is properly configured
   az monitor app-insights component show --app secure-func-n2cte9-ai --resource-group milestones-we-dev

   # Verify Log Analytics workspace
   az monitor log-analytics workspace show --workspace-name secure-func-n2cte9-law --resource-group milestones-we-dev
   ```

6. Test the KQL queries:
   ```bash
   # Follow the queries in the milestone2/queries directory
   # You can run these queries in the Azure Portal Log Analytics workspace
   ```

## Milestone 3: Storage Account Auditing with KQL Queries

1. Navigate to the Milestone 3 directory:
   ```bash
   cd ../milestone3/terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init -backend-config="storage_account_name=tfstateq0m19cdw" \
                 -backend-config="container_name=tfstate" \
                 -backend-config="key=milestone3.tfstate" \
                 -backend-config="resource_group_name=tfstate-rg"
   ```

3. Review the deployment plan:
   ```bash
   terraform plan -out=milestone3.tfplan -var="resource_group_name=milestones-we-dev" -var="location=westeurope" -var="suffix=n2cte9"
   ```

4. Apply the deployment:
   ```bash
   terraform apply "milestone3.tfplan"
   ```

5. Verify the deployment:
   ```bash
   # Verify Storage Account configuration
   az storage account show --name funcsan2cte9 --resource-group milestones-we-dev
   
   # Verify diagnostic settings
   az monitor diagnostic-settings list --resource $(az storage account show --name funcsan2cte9 --resource-group milestones-we-dev --query id -o tsv)
   ```

6. Test the KQL audit queries:
   ```bash
   # Follow the queries in the milestone3/queries directory
   # You can run these queries in the Azure Portal Log Analytics workspace
   ```

## Milestone 4: Network Isolation with Private Endpoints

1. Navigate to the Milestone 4 directory:
   ```bash
   cd ../milestone4/terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init -backend-config="storage_account_name=tfstateq0m19cdw" \
                 -backend-config="container_name=tfstate" \
                 -backend-config="key=milestone4.tfstate" \
                 -backend-config="resource_group_name=tfstate-rg"
   ```

3. Review the deployment plan:
   ```bash
   terraform plan -out=milestone4.tfplan -var="resource_group_name=milestones-we-dev" -var="location=westeurope" -var="suffix=n2cte9"
   ```

4. Apply the deployment:
   ```bash
   terraform apply "milestone4.tfplan"
   ```

5. Verify the deployment:
   ```bash
   # Verify VNet deployment
   az network vnet show --name vnet-milestone4-n2cte9 --resource-group milestones-we-dev
   
   # Verify Private Endpoint configuration
   az network private-endpoint show --name pe-function-n2cte9 --resource-group milestones-we-dev
   
   # Verify Web App deployment
   az webapp show --name webapp-n2cte9 --resource-group milestones-we-dev
   ```

6. Test connectivity from Web App to Function App:
   - Navigate to the Azure Portal
   - Open the Web App (webapp-n2cte9)
   - Go to Development Tools > Console
   - Run `curl -i https://secure-func-n2cte9.azurewebsites.net/api/ScheduledRandomNumber`
   - Verify you receive a successful response

## Milestone 5: PowerShell Automation

1. Navigate to the Milestone 5 directory:
   ```bash
   cd ../milestone5/terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init -backend-config="storage_account_name=tfstateq0m19cdw" \
                 -backend-config="container_name=tfstate" \
                 -backend-config="key=milestone5.tfstate" \
                 -backend-config="resource_group_name=tfstate-rg"
   ```

3. Review the deployment plan:
   ```bash
   terraform plan -out=milestone5.tfplan -var="resource_group_name=milestones-we-dev" -var="location=westeurope" -var="suffix=n2cte9"
   ```

4. Apply the deployment:
   ```bash
   terraform apply "milestone5.tfplan"
   ```

5. Verify the deployment and deploy the function:
   ```bash
   # Make the deployment script executable
   chmod +x ./deploy_function.sh
   
   # Deploy the function
   ./deploy_function.sh
   ```

6. Test the local PowerShell script:
   ```powershell
   # Run the test script
   ./test_local_script.ps1
   
   # Or run the script directly
   ./Generate-RandomNumberFile.ps1 -StorageAccountName 'funcsan2cte9' -ResourceGroupName 'milestones-we-dev'
   ```

7. Verify the function runs on schedule:
   ```bash
   # Check function logs
   az functionapp log tail --name secure-func-n2cte9 --resource-group milestones-we-dev
   
   # Check for new files in the blob container
   az storage blob list --account-name funcsan2cte9 --container-name generated-files --output table
   ```

## Troubleshooting

If you encounter issues during deployment:

1. Check the Terraform logs for detailed error messages
2. Ensure your Azure account has the necessary permissions
3. Verify that resource naming follows Azure restrictions
4. Check for resource quota limitations in your subscription
5. Make sure the region "West Europe" is available in your subscription

For function-specific issues:
1. Check the function logs in the Azure Portal
2. Verify the function app settings are correctly configured
3. Ensure that managed identity permissions are properly set up

## Clean Up

To remove all resources:

```bash
# Go to each milestone directory and run:
terraform destroy -var="resource_group_name=milestones-we-dev" -var="location=westeurope" -var="suffix=n2cte9"

# Or remove the entire resource group:
az group delete --name milestones-we-dev --yes --no-wait
```
