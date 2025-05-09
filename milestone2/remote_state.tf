# Access Milestone 1 state to reference resources
data "terraform_remote_state" "milestone1" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateq0m19cdw"
    container_name       = "tfstate"
    key                  = "milestone1.tfstate"
  }
}

# Current Azure client context
data "azurerm_client_config" "current" {}

# Local variables for easy reference to milestone1 outputs
locals {
  resource_group_name  = data.terraform_remote_state.milestone1.outputs.resource_group_name
  function_app_name    = data.terraform_remote_state.milestone1.outputs.function_app_name
  function_app_id      = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Web/sites/${local.function_app_name}"
  storage_account_name = data.terraform_remote_state.milestone1.outputs.storage_account_name
  storage_account_id   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"
  key_vault_name       = data.terraform_remote_state.milestone1.outputs.key_vault_name
  key_vault_id         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.KeyVault/vaults/${local.key_vault_name}"

  # Get the suffix from the function app name
  suffix = "n2cte9"

  # Resource location (based on westeurope)
  location = "westeurope"

  # Tags
  tags = {
    Environment = "Development"
    Project     = "SecureFunctionApp"
    ManagedBy   = "Terraform"
    Owner       = "CloudTeam"
    Milestone   = "2"
  }
}