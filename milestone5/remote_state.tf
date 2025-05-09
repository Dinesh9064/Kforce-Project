# Access Milestone 1 state for core resources
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

# Local variables for easy reference to previous milestone outputs
locals {
  # Core resources from Milestone 1 - these are the only dependencies we need
  resource_group_name  = data.terraform_remote_state.milestone1.outputs.resource_group_name
  function_app_name    = data.terraform_remote_state.milestone1.outputs.function_app_name
  storage_account_name = data.terraform_remote_state.milestone1.outputs.storage_account_name

  # Get Storage Account details
  storage_account_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"

  # Get the suffix from the function app name for consistent naming
  suffix = element(split("-", local.function_app_name), length(split("-", local.function_app_name)) - 1)

  # Resource location (based on West Europe)
  location = "westeurope"

  # Tags
  tags = {
    Environment = "Development"
    Project     = "SecureFunctionApp"
    ManagedBy   = "Terraform"
    Owner       = "CloudTeam"
    Milestone   = "5"
  }
}