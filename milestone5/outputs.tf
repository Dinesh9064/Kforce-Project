# Pass through values from previous milestones
output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = local.function_app_name
}

output "storage_account_name" {
  description = "Name of the Azure Storage Account"
  value       = local.storage_account_name
}

# Milestone 5 specific outputs
output "blob_container_name" {
  description = "Name of the container for generated files"
  value       = azurerm_storage_container.generated_files.name
}

output "local_script_path" {
  description = "Path to the local PowerShell script"
  value       = local_file.local_ps_script.filename
}

output "function_zip_path" {
  description = "Path to the function ZIP file"
  value       = data.archive_file.function_zip.output_path
}

output "deploy_script_path" {
  description = "Path to the deployment script (Bash)"
  value       = local_file.deploy_script.filename
}

output "deploy_script_ps_path" {
  description = "Path to the deployment script (PowerShell)"
  value       = local_file.deploy_script_ps.filename
}

output "test_local_script_path" {
  description = "Path to the test script for the local PowerShell script"
  value       = local_file.test_local_script.filename
}

output "cron_schedule" {
  description = "CRON expression for the scheduled function"
  value       = var.cron_expression
}

output "function_name" {
  description = "Name of the function in the Function App"
  value       = var.function_name
}

output "local_script_usage" {
  description = "Usage instructions for the local PowerShell script"
  value       = "Run: ./${var.powershell_script_name} -StorageAccountName '${local.storage_account_name}' -ResourceGroupName '${local.resource_group_name}'"
}

output "deployment_instructions" {
  description = "Instructions for deploying the function"
  value       = "Run: chmod +x ${local_file.deploy_script.filename} && ${local_file.deploy_script.filename}"
}