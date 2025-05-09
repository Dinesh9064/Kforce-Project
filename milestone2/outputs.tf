# Pass through values from Milestone 1
output "resource_group_name" {
  description = "Name of the resource group from Milestone 1"
  value       = local.resource_group_name
}

output "function_app_name" {
  description = "Name of the Azure Function App from Milestone 1"
  value       = local.function_app_name
}

output "function_app_hostname" {
  description = "Hostname of the Function App from Milestone 1"
  value       = data.terraform_remote_state.milestone1.outputs.function_app_hostname
}

output "function_app_url" {
  description = "URL of the Function App from Milestone 1"
  value       = data.terraform_remote_state.milestone1.outputs.function_app_url
}

output "storage_account_name" {
  description = "Name of the Azure Storage Account from Milestone 1"
  value       = local.storage_account_name
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault from Milestone 1"
  value       = local.key_vault_name
}

output "key_vault_uri" {
  description = "URI endpoint of the Azure Key Vault from Milestone 1"
  value       = data.terraform_remote_state.milestone1.outputs.key_vault_uri
}

# Milestone 2 specific outputs
output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.name
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.app_insights.name
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "application_insights_app_id" {
  description = "App ID for Application Insights"
  value       = azurerm_application_insights.app_insights.app_id
}