output "resource_group_name" {
  description = "Name of the deployed resource group"
  value       = azurerm_resource_group.rg.name
}

output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = azurerm_windows_function_app.func.name
}

output "function_app_hostname" {
  description = "Hostname of the Function App (used internally)"
  value       = azurerm_windows_function_app.func.default_hostname
}


output "storage_account_name" {
  description = "Name of the Azure Storage Account"
  value       = azurerm_storage_account.sa.name
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "URI endpoint of the Azure Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

# Output Function App URL
output "function_app_url" {
  value = "https://${azurerm_windows_function_app.func.default_hostname}/api/"
}