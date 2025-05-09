# Pass through values from previous milestones
output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = local.function_app_name
}

output "function_app_hostname" {
  description = "Hostname of the Function App"
  value       = data.terraform_remote_state.milestone1.outputs.function_app_hostname
}

output "function_app_url" {
  description = "URL of the Function App"
  value       = data.terraform_remote_state.milestone1.outputs.function_app_url
}

output "storage_account_name" {
  description = "Name of the Azure Storage Account"
  value       = local.storage_account_name
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault"
  value       = local.key_vault_name
}

output "key_vault_uri" {
  description = "URI endpoint of the Azure Key Vault"
  value       = data.terraform_remote_state.milestone1.outputs.key_vault_uri
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = local.log_analytics_workspace_name
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = local.log_analytics_workspace_id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = local.application_insights_name
}

# Milestone 3 specific outputs
output "audit_test_container_name" {
  description = "Name of the test container created for audit testing"
  value       = azurerm_storage_container.audit_test_container.name
}

output "audit_test_share_name" {
  description = "Name of the test file share created for audit testing"
  value       = azurerm_storage_share.audit_test_share.name
}

output "blob_audit_queries_file" {
  description = "Path to the file containing blob audit KQL queries"
  value       = local_file.blob_audit_kql.filename
}

output "file_share_audit_queries_file" {
  description = "Path to the file containing file share audit KQL queries"
  value       = local_file.file_share_audit_kql.filename
}

output "combined_audit_queries_file" {
  description = "Path to the file containing combined storage audit KQL queries"
  value       = local_file.combined_audit_kql.filename
}

output "blob_diagnostic_setting_id" {
  description = "ID of the blob service diagnostic setting for auditing"
  value       = azurerm_monitor_diagnostic_setting.blob_audit.id
}

output "file_diagnostic_setting_id" {
  description = "ID of the file service diagnostic setting for auditing"
  value       = azurerm_monitor_diagnostic_setting.file_audit.id
}