# Access previous milestone states
data "terraform_remote_state" "milestone1" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateq0m19cdw"
    container_name       = "tfstate"
    key                  = "milestone1.tfstate"
  }
}

data "terraform_remote_state" "milestone2" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateq0m19cdw"
    container_name       = "tfstate"
    key                  = "milestone2.tfstate"
  }
}

data "terraform_remote_state" "milestone3" {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateq0m19cdw"
    container_name       = "tfstate"
    key                  = "milestone3.tfstate"
  }
}

# Current Azure client context
data "azurerm_client_config" "current" {}

# Local variables for easy reference to previous milestones' outputs
locals {
  # Core resources from Milestone 1
  resource_group_name  = data.terraform_remote_state.milestone1.outputs.resource_group_name
  function_app_name    = data.terraform_remote_state.milestone1.outputs.function_app_name
  storage_account_name = data.terraform_remote_state.milestone1.outputs.storage_account_name
  key_vault_name       = data.terraform_remote_state.milestone1.outputs.key_vault_name
  key_vault_uri        = data.terraform_remote_state.milestone1.outputs.key_vault_uri

  # Monitoring resources from Milestone 2
  log_analytics_workspace_id   = data.terraform_remote_state.milestone2.outputs.log_analytics_workspace_id
  log_analytics_workspace_name = data.terraform_remote_state.milestone2.outputs.log_analytics_workspace_name
  application_insights_name    = data.terraform_remote_state.milestone2.outputs.application_insights_name

  # Storage account auditing from Milestone 3
  audit_test_container_name = data.terraform_remote_state.milestone3.outputs.audit_test_container_name
  audit_test_share_name     = data.terraform_remote_state.milestone3.outputs.audit_test_share_name

  # Resource IDs for reference
  function_app_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Web/sites/${local.function_app_name}"
  storage_account_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"
  key_vault_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.KeyVault/vaults/${local.key_vault_name}"

  # Get the suffix from the function app name
  suffix = "n2cte9"

  # Resource location (based on West Europe)
  location = "westeurope"

  # Tags
  tags = {
    Environment = "Development"
    Project     = "SecureFunctionApp"
    ManagedBy   = "Terraform"
    Owner       = "CloudTeam"
    Milestone   = "4"
  }
}