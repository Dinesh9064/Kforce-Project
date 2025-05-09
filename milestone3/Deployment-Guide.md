# Milestone 3 Deployment Guide

This guide provides step-by-step instructions for deploying Milestone 3, which implements storage account auditing capabilities.

## Prerequisites

- Successful deployment of Milestones 1 and 2
- Azure CLI installed and configured
- Terraform installed
- Access to the Azure subscription with appropriate permissions

## File Structure

Ensure you have the following files in your `milestone3` directory:

```
milestone3/
├── remote_state.tf       # References resources from Milestones 1 and 2
├── provider.tf           # Provider configuration
├── main.tf               # Storage audit implementation
├── variables.tf          # Milestone-specific variables
├── outputs.tf            # Output values
├── terraform.tfvars      # Variable values
├── backend.conf          # Backend configuration
├── README.md             # Documentation
```

## Deployment Steps

Follow these steps to deploy Milestone 3:

1. **Initialize Terraform with the backend configuration**:
   ```bash
   cd milestone3
   terraform init -backend-config=backend.conf
   ```

2. **Verify the deployment plan**:
   ```bash
   terraform plan -out=tfplan
   ```

   Review the plan to ensure that:
    - No existing resources will be recreated or modified unexpectedly
    - New diagnostic settings will be applied to the storage account
    - Test container and file share will be created
    - KQL query files will be generated locally

3. **Apply the configuration**:
   ```bash
   terraform apply tfplan
   ```

4. **Verify the deployment**:
    - Check that the test container and file share have been created
    - Verify that diagnostic settings have been applied to the storage account
    - Examine the KQL query files created in your local directory

## Validation Steps

1. **Verify diagnostic settings**:
   ```bash
   az monitor diagnostic-settings show \
     --resource $(terraform output -raw storage_account_id) \
     --name storage-audit-settings
   ```

2. **Perform test operations on the storage account**:
   ```bash
   # Upload a test file to the blob container
   echo "Test content" > test.txt
   az storage blob upload \
     --account-name $(terraform output -raw storage_account_name) \
     --container-name $(terraform output -raw audit_test_container_name) \
     --name test.txt \
     --file test.txt \
     --auth-mode login
     
   # List blobs in the container
   az storage blob list \
     --account-name $(terraform output -raw storage_account_name) \
     --container-name $(terraform output -raw audit_test_container_name) \
     --auth-mode login
     
   # Download the file from the file share
   az storage file download \
     --account-name $(terraform output -raw storage_account_name) \
     --share-name $(terraform output -raw audit_test_share_name) \
     --path sample_share.txt \
     --dest sample_share_downloaded.txt \
     --auth-mode login
   ```

3. **Run KQL queries**:
    - Go to the Azure Portal
    - Navigate to your Log Analytics workspace
    - Open the "Logs" blade
    - Copy and paste a query from one of the .kql files
    - Click "Run" to execute the query
    - You should see the audit logs from your test operations

   Note: It may take up to 30 minutes for logs to appear in Log Analytics.

## Troubleshooting

1. **Logs not appearing in Log Analytics**:
    - Verify that diagnostic settings are properly configured
    - Allow sufficient time for logs to be ingested (up to 30 minutes)
    - Check for any errors in the diagnostic settings configuration

2. **Access issues when performing test operations**:
    - Ensure you have appropriate RBAC permissions on the storage account
    - Verify that you're authenticated with the Azure CLI

3. **Terraform errors**:
    - Check that your backend.conf file points to the correct storage account
    - Verify that remote state references are correct
    - Ensure your Azure credentials have the necessary permissions

## Next Steps

After successfully deploying Milestone 3:

1. Review the generated KQL queries to understand the available auditing capabilities
2. Experiment with the queries