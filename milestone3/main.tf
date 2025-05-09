# Milestone 3: Storage Account Auditing

# Enable diagnostics settings for blob services
resource "azurerm_monitor_diagnostic_setting" "blob_audit" {
  name                       = "blob-audit-diag"
  target_resource_id         = "${local.storage_account_id}/blobServices/default"
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }
}

# Enable diagnostics settings for file services
resource "azurerm_monitor_diagnostic_setting" "file_audit" {
  name                       = "file-audit-diag"
  target_resource_id         = "${local.storage_account_id}/fileServices/default"
  log_analytics_workspace_id = local.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }
}

# Create sample container and file for testing audit
resource "azurerm_storage_container" "audit_test_container" {
  name                  = "audit-test"
  storage_account_name  = local.storage_account_name
  container_access_type = "private"
}

# Get storage account details for key
data "azurerm_storage_account" "details" {
  name                = local.storage_account_name
  resource_group_name = local.resource_group_name
}

# Generate a sample blob using key authentication
resource "null_resource" "upload_sample_blob" {
  depends_on = [
    azurerm_storage_container.audit_test_container,
    azurerm_monitor_diagnostic_setting.blob_audit
  ]

  provisioner "local-exec" {
    command = <<EOT
# Create a sample file
echo "This is a sample file for storage account audit testing. Created at $(date)" > sample.txt

# Upload the file to the container using account key instead of RBAC
az storage blob upload \
  --account-name ${local.storage_account_name} \
  --account-key "${data.azurerm_storage_account.details.primary_access_key}" \
  --container-name ${azurerm_storage_container.audit_test_container.name} \
  --name sample.txt \
  --file sample.txt
EOT
  }
}

# Create a file share for testing file share audit
resource "azurerm_storage_share" "audit_test_share" {
  name                 = "audittestshare"
  storage_account_name = local.storage_account_name
  quota                = 5
}

# Generate a sample file in the share using key authentication
resource "null_resource" "upload_sample_file" {
  depends_on = [
    azurerm_storage_share.audit_test_share,
    azurerm_monitor_diagnostic_setting.file_audit
  ]

  provisioner "local-exec" {
    command = <<EOT
# Create a sample file
echo "This is a sample file for file share audit testing. Created at $(date)" > sample_share.txt

# Upload the file to the file share using account key instead of RBAC
az storage file upload \
  --account-name ${local.storage_account_name} \
  --account-key "${data.azurerm_storage_account.details.primary_access_key}" \
  --share-name ${azurerm_storage_share.audit_test_share.name} \
  --source sample_share.txt \
  --path sample_share.txt
EOT
  }
}

# Create KQL scripts for auditing - updated for supported log categories
resource "local_file" "blob_audit_kql" {
  content = <<EOT
// Query 1: Audit all blob storage read operations
StorageBlobLogs
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where TimeGenerated > ago(7d)
| where OperationName has "read" or OperationName has "get"
| project TimeGenerated, OperationName, Uri, CallerIpAddress, UserAgentHeader, StatusCode, StatusText
| sort by TimeGenerated desc

// Query 2: Audit failed access attempts to blobs
StorageBlobLogs
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where StatusCode !between (200 .. 299)
| project TimeGenerated, OperationName, Uri, CallerIpAddress, UserAgentHeader, StatusCode, StatusText
| sort by TimeGenerated desc

// Query 3: Audit all blob storage write operations
StorageBlobLogs
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where TimeGenerated > ago(7d)
| where OperationName has "write" or OperationName has "put" or OperationName has "create"
| project TimeGenerated, OperationName, Uri, CallerIpAddress, UserAgentHeader, StatusCode, StatusText
| sort by TimeGenerated desc

// Query 4: Audit all blob storage delete operations
StorageBlobLogs
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where TimeGenerated > ago(7d)
| where OperationName has "delete"
| project TimeGenerated, OperationName, Uri, CallerIpAddress, UserAgentHeader, StatusCode, StatusText
| sort by TimeGenerated desc
EOT
  filename = "${path.module}/blob_audit_queries.kql"
}

resource "local_file" "file_share_audit_kql" {
  content = <<EOT
// Query 1: Audit file share read operations
StorageFileLogs
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where TimeGenerated > ago(7d)
| where OperationName has "read" or OperationName has "get"
| project TimeGenerated, OperationName, Uri, CallerIpAddress, UserAgentHeader, StatusCode, StatusText
| sort by TimeGenerated desc

// Query 2: Audit failed file share operations
StorageFileLogs
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where StatusCode !between (200 .. 299)
| project TimeGenerated, OperationName, Uri, CallerIpAddress, UserAgentHeader, StatusCode, StatusText
| sort by TimeGenerated desc

// Query 3: Audit file share write operations
StorageFileLogs
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where TimeGenerated > ago(7d)
| where OperationName has "write" or OperationName has "put" or OperationName has "create"
| project TimeGenerated, OperationName, Uri, CallerIpAddress, UserAgentHeader, StatusCode, StatusText
| sort by TimeGenerated desc

// Query 4: Audit file share delete operations
StorageFileLogs
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where TimeGenerated > ago(7d)
| where OperationName has "delete"
| project TimeGenerated, OperationName, Uri, CallerIpAddress, UserAgentHeader, StatusCode, StatusText
| sort by TimeGenerated desc
EOT
  filename = "${path.module}/file_share_audit_queries.kql"
}

resource "local_file" "combined_audit_kql" {
  content = <<EOT
// Query 1: Audit all storage operations by type
search in (StorageBlobLogs, StorageFileLogs)
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where TimeGenerated > ago(7d)
| extend ResourceType = iif(TableName == "StorageBlobLogs", "Blob", "FileShare")
| summarize OperationCount=count() by ResourceType, OperationName, bin(TimeGenerated, 1d)
| sort by TimeGenerated desc, ResourceType, OperationCount desc

// Query 2: Top users accessing storage by IP address
search in (StorageBlobLogs, StorageFileLogs)
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where TimeGenerated > ago(7d)
| summarize OperationCount=count() by CallerIpAddress
| top 10 by OperationCount desc

// Query 3: Security-focused audit for suspicious activities
search in (StorageBlobLogs, StorageFileLogs)
| where AccountName == "${local.storage_account_name}" or resourceId contains "${local.storage_account_name}"
| where TimeGenerated > ago(7d)
| where StatusCode !between (200 .. 299)
| extend ResourceType = iif(TableName == "StorageBlobLogs", "Blob", "FileShare")
| project TimeGenerated, ResourceType, OperationName, Uri, CallerIpAddress, UserAgentHeader, StatusCode, StatusText
| sort by TimeGenerated desc
EOT
  filename = "${path.module}/combined_audit_queries.kql"
}

# Create a README file with instructions on how to run the KQL queries
resource "local_file" "kql_readme" {
  content = <<EOT
# Storage Account Audit KQL Queries

This directory contains Kusto Query Language (KQL) queries for auditing access to Storage Account blobs and file shares.

## Prerequisites

- Azure Log Analytics Workspace with storage account diagnostic logs
- Access to Azure Portal or Azure Data Explorer

## How to Run the Queries

1. Go to the Azure Portal
2. Navigate to your Log Analytics Workspace: "${local.log_analytics_workspace_name}"
3. Select "Logs" from the left menu
4. Copy and paste any of the queries from the .kql files in this directory
5. Click "Run" to execute the query

## Available Query Files

- **blob_audit_queries.kql**: Queries for auditing blob storage operations
- **file_share_audit_queries.kql**: Queries for auditing file share operations
- **combined_audit_queries.kql**: Queries that combine multiple storage services for comprehensive auditing

## Important Notes

- The queries are configured for storage account: "${local.storage_account_name}"
- Log data might take up to 30 minutes to appear in Log Analytics after operations occur
- Customize the time range in the queries as needed by changing the `ago(7d)` parameter

## Example Output

The queries will return information such as:
- Operation timestamps
- Operation types (read, write, delete)
- Source IP addresses
- Status codes
- User agents
- URI paths

This data can be used to identify who or what has been accessing your storage resources, detect unauthorized access attempts, and monitor usage patterns.
EOT
  filename = "${path.module}/README_KQL_QUERIES.md"
}