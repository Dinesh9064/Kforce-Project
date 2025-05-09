# Pass through values from previous milestones
output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
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
  value       = local.key_vault_uri
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

# Milestone 4 specific outputs
output "original_function_app_name" {
  description = "Name of the original public Function App from Milestone 1"
  value       = local.function_app_name
}

output "private_function_app_name" {
  description = "Name of the private Function App"
  value       = azurerm_windows_function_app.private_func.name
}

output "private_function_app_hostname" {
  description = "Hostname of the private Function App"
  value       = azurerm_windows_function_app.private_func.default_hostname
}

output "private_function_app_id" {
  description = "Resource ID of the private Function App"
  value       = azurerm_windows_function_app.private_func.id
}

output "web_app_name" {
  description = "Name of the Web App"
  value       = azurerm_windows_web_app.webapp.name
}

output "web_app_hostname" {
  description = "Hostname of the Web App"
  value       = azurerm_windows_web_app.webapp.default_hostname
}

output "web_app_url" {
  description = "URL of the Web App"
  value       = "https://${azurerm_windows_web_app.webapp.default_hostname}"
}

output "function_vnet_name" {
  description = "Name of the Virtual Network for the Function App"
  value       = azurerm_virtual_network.func_vnet.name
}

output "function_subnet_name" {
  description = "Name of the subnet for the Function App"
  value       = azurerm_subnet.func_subnet.name
}

output "webapp_vnet_name" {
  description = "Name of the Virtual Network for the Web App"
  value       = azurerm_virtual_network.webapp_vnet.name
}

output "webapp_subnet_name" {
  description = "Name of the subnet for the Web App"
  value       = azurerm_subnet.webapp_subnet.name
}

output "function_private_endpoint_name" {
  description = "Name of the private endpoint for the Function App"
  value       = azurerm_private_endpoint.function_endpoint.name
}

output "function_private_endpoint_ip" {
  description = "Private IP address of the Function App private endpoint"
  value       = azurerm_private_endpoint.function_endpoint.private_service_connection[0].private_ip_address
}

output "test_html_path" {
  description = "Path to the test HTML file for validating connectivity"
  value       = local_file.test_html.filename
}

output "deploy_script_path" {
  description = "Path to the deployment script for the Web App"
  value       = local_file.deploy_webapp_script.filename
}

output "web_app_deployment_instructions" {
  description = "Instructions for deploying the test page to the Web App"
  value       = "Run the deployment script: chmod +x ${local_file.deploy_webapp_script.filename} && ${local_file.deploy_webapp_script.filename}"
}