# Milestone 5: PowerShell Automation - Deployment Guide

This guide provides detailed instructions for deploying and verifying the PowerShell automation components for Milestone 5 of the Azure Function App Secure Deployment project.

## Overview

Milestone 5 implements PowerShell automation for generating random number files and storing them in Azure Blob Storage. The implementation includes:

- PowerShell script for generating random numbers
- Azure Function with timer trigger for scheduled execution
- Blob storage integration for storing generated files
- Terraform configuration for deployment automation

## Prerequisites

- Azure CLI installed and configured
- Terraform installed (version 1.3.0+)
- PowerShell installed (version 7.0+)
- Previous milestones successfully deployed
- Azure Function Core Tools (if local testing is required)

## Deployment Steps

### 1. Prepare Your Environment

```bash
# Navigate to the Milestone 5 directory
cd milestone5/terraform

# Ensure Azure CLI is logged in
az login

# Set your subscription
az account set --subscription "your-subscription-id"
```

### 2. Initialize Terraform

```bash
# Initialize Terraform with backend configuration
terraform init -backend-config="storage_account_name=tfstateq0m19cdw" \
               -backend-config="container_name=tfstate" \
               -backend-config="key=milestone5.tfstate" \
               -backend-config="resource_group_name=tfstate-rg"
```

### 3. Create Terraform Plan

```bash
# Create a deployment plan
terraform plan -out=milestone5.tfplan \
               -var="resource_group_name=milestones-we-dev" \
               -var="location=westeurope" \
               -var="suffix=n2cte9"
```

### 4. Apply Terraform Configuration

```bash
# Apply the Terraform plan
terraform apply "milestone5.tfplan"
```

### 5. Review Terraform Outputs

After successful deployment, review the outputs to understand the resources created and next steps:

```bash
# View all outputs
terraform output

# Important outputs include:
# - function_app_name: Name of the Azure Function App
# - storage_account_name: Name of the storage account
# - blob_container_name: Name of the blob container for generated files
# - function_name: Name of the Azure Function
# - cron_schedule: Schedule for the timer trigger
# - local_script_path: Path to the local PowerShell script
# - deploy_script_path: Path to the deployment script
```

### 6. Deploy the Azure Function

The Terraform deployment creates a deployment script. Use it to deploy the function code:

```bash
# Make the deployment script executable
chmod +x ./deploy_function.sh

# Deploy the function
./deploy_function.sh
```

This script:
- Creates a ZIP package with the function code
- Deploys it to the Azure Function App
- Sets up necessary application settings

If you're using Windows:

```powershell
# Use the PowerShell deployment script
.\deploy_function.ps1
```

## Verification Steps

Follow these steps to verify that all components of Milestone 5 are functioning correctly:

### 1. Verify Storage Container

```bash
# Verify that the storage container exists
az storage container show \
  --name generated-files \
  --account-name funcsan2cte9 \
  --resource-group milestones-we-dev
```

Expected output: Container details including name, last-modified, and lease status.

### 2. Verify Function App Deployment

```bash
# Check the Function App exists and is running
az functionapp show \
  --name secure-func-n2cte9 \
  --resource-group milestones-we-dev \
  --query "{Name:name,State:state,DefaultHostName:defaultHostName}"
```

Expected output: JSON with the Function App name, state (should be "Running"), and default host name.

### 3. Verify Function Configuration

```bash
# Check the function's application settings
az functionapp config appsettings list \
  --name secure-func-n2cte9 \
  --resource-group milestones-we-dev \
  --query "[?name=='STORAGE_ACCOUNT_NAME' || name=='CONTAINER_NAME' || name=='WEBSITE_TIME_ZONE']"
```

Expected output: List of application settings related to the storage account and container name.

### 4. Test the Timer Trigger

```bash
# View the function logs to verify timer trigger execution
az functionapp log tail \
  --name secure-func-n2cte9 \
  --resource-group milestones-we-dev
```

Wait for the logs to show the timer trigger execution. You should see messages indicating:
- Function execution started
- Generation of a random number
- Storage of the file in the blob container
- Function execution completed successfully

Press `Ctrl+C` to exit the log view.

### 5. Test the Local PowerShell Script

```powershell
# Run the local PowerShell script
.\Generate-RandomNumberFile.ps1 -StorageAccountName 'funcsan2cte9' -ResourceGroupName 'milestones-we-dev'
```

Expected output: Confirmation that a random number file was generated and uploaded to the blob container.

### 6. Verify Files in Blob Storage

```bash
# List files in the blob container
az storage blob list \
  --container-name generated-files \
  --account-name funcsan2cte9 \
  --resource-group milestones-we-dev \
  --output table
```

Expected output: Table listing blobs in the container, including their names, creation times, and sizes.

### 7. Check Function Execution History

```bash
# View the function execution history
az monitor activity-log list \
  --resource-group milestones-we-dev \
  --resource-provider Microsoft.Web \
  --resource-type sites \
  --resource secure-func-n2cte9 \
  --query "[?contains(operationName.value, 'functions')].{Operation:operationName.localizedValue,Status:status.localizedValue,Time:eventTimestamp}" \
  --output table
```

Expected output: Table showing recent function executions with their status and timestamps.

## Detailed Function Verification

For deeper verification, you can download and check the content of the generated files:

```bash
# Get a list of files
az storage blob list \
  --container-name generated-files \
  --account-name funcsan2cte9 \
  --resource-group milestones-we-dev \
  --query "[].{Name:name}" \
  --output tsv > blob_list.txt

# Download the most recent file (first in the list)
LATEST_BLOB=$(head -n 1 blob_list.txt)
az storage blob download \
  --container-name generated-files \
  --name "$LATEST_BLOB" \
  --account-name funcsan2cte9 \
  --resource-group milestones-we-dev \
  --file latest_random_number.txt

# Display the file content
cat latest_random_number.txt
```

Expected output: A text file containing a random number between 1 and 100.

## Manual Testing in Azure Portal

You can also verify the function through the Azure Portal:

1. Navigate to the Azure Portal (https://portal.azure.com)
2. Go to the Function App (secure-func-n2cte9)
3. Select the "Functions" blade
4. Click on the "ScheduledRandomNumber" function
5. Go to the "Code + Test" tab
6. Click "Test/Run" to manually trigger the function
7. Review the logs to confirm successful execution
8. Check the blob container to verify a new file was created

## Troubleshooting

If you encounter issues during deployment or verification:

### Function App Not Working

```bash
# Check the application settings
az functionapp config appsettings list \
  --name secure-func-n2cte9 \
  --resource-group milestones-we-dev
```

Ensure all required settings are present including:
- STORAGE_ACCOUNT_NAME
- CONTAINER_NAME
- AzureWebJobsStorage
- WEBSITE_TIME_ZONE

### Unable to Upload Files to Blob Storage

```bash
# Check the managed identity has proper permissions
az role assignment list \
  --assignee $(az functionapp identity show \
    --name secure-func-n2cte9 \
    --resource-group milestones-we-dev \
    --query principalId -o tsv) \
  --scope $(az storage account show \
    --name funcsan2cte9 \
    --resource-group milestones-we-dev \
    --query id -o tsv)
```

Ensure the function app's managed identity has "Storage Blob Data Contributor" role assigned.

### Timer Trigger Not Running

```bash
# Check the function.json configuration
az functionapp function config list \
  --name secure-func-n2cte9 \
  --resource-group milestones-we-dev \
  --function-name ScheduledRandomNumber
```

Verify the schedule expression is correctly formatted and matches the expected cron expression (0 30 3,9,15,21 * *1,3,5).

## Next Steps

After verifying the successful deployment and operation of Milestone 5:

1. Document any customizations made to the default implementation
2. Consider setting up monitoring alerts for function failures
3. Ensure the function logs are properly integrated with Log Analytics (from Milestone 2)
4. Review the security of the entire solution end-to-end

## Clean Up

If you need to remove the resources:

```bash
# Remove just the Milestone 5 resources
terraform destroy \
  -var="resource_group_name=milestones-we-dev" \
  -var="location=westeurope" \
  -var="suffix=n2cte9"
```

Note: This will not remove resources created in previous milestones.
