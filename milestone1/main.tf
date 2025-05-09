# Get current client configuration for tenant ID
data "azurerm_client_config" "current" {}

# Random suffix for unique naming
# resource "random_string" "suffix" {
#   length  = 6
#   special = false
#   upper   = false
# }

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  keepers = {
    fixed = "mxsvo5"
  }
}


# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# Storage Account
resource "azurerm_storage_account" "sa" {
  name                     = "funcsa${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

# App Service Plan (Y1 Consumption)
resource "azurerm_service_plan" "asp" {
  name                = "func-asp-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "Y1"

  tags = var.tags
}

# Function App
resource "azurerm_windows_function_app" "func" {
  name                       = "secure-func-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      powershell_core_version = "7.2"
    }
    http2_enabled       = true
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1",
    "FUNCTIONS_WORKER_RUNTIME" = "powershell",
    "API_KEY"                  = "PLACEHOLDER"
  }

  tags = var.tags
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                       = "func-kv-${random_string.suffix.result}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  enable_rbac_authorization  = false

  tags = var.tags
}

# Access Policy for Terraform
resource "azurerm_key_vault_access_policy" "terraform_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = ["Get", "List", "Create", "Delete", "Update"]
  secret_permissions = ["Get", "List", "Set", "Delete"]
}

# Wait for Key Vault access propagation
resource "time_sleep" "wait_terraform" {
  depends_on = [azurerm_key_vault_access_policy.terraform_policy]
  create_duration = "30s"
}

# Secret in Key Vault
resource "azurerm_key_vault_secret" "api_key" {
  name         = "API-KEY"
  value        = "aaaaaAAAAAbbbbbbBBBBBcccccCCCCCdddddDDDDD"
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_terraform]
}

# Access Policy for Function App Identity
resource "azurerm_key_vault_access_policy" "func_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_function_app.func.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

# Wait for Function App access propagation
resource "time_sleep" "wait_func_policy" {
  depends_on = [azurerm_key_vault_access_policy.func_policy]
  create_duration = "30s"
}

# Patch app settings using az CLI (null_resource)
resource "null_resource" "patch_app_settings" {
  depends_on = [
    time_sleep.wait_func_policy,
    azurerm_key_vault_secret.api_key
  ]

  provisioner "local-exec" {
    command = <<EOT
az functionapp config appsettings set \
  --name ${azurerm_windows_function_app.func.name} \
  --resource-group ${azurerm_windows_function_app.func.resource_group_name} \
  --settings "API_KEY=@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.api_key.id})"
EOT
  }
}

# Sample HTTP Trigger Function JSON
resource "local_file" "test_function_json" {
  content = <<EOF
{
  "bindings": [
    {
      "authLevel": "function",
      "type": "httpTrigger",
      "direction": "in",
      "name": "Request",
      "methods": [
        "get",
        "post"
      ]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "Response"
    }
  ]
}
EOF
  filename = "${path.module}/function/function.json"
}

# # Sample Function Code
# resource "local_file" "test_function_code" {
#   content = <<EOF
# using namespace System.Net
#
# param(\$Request, \$TriggerMetadata)
#
# \$apiKey = \$env:API_KEY
#
# Write-Host "API Key successfully retrieved: \$apiKey"
#
# \$body = @{
#     Message = "API Key was successfully retrieved from Key Vault"
#     ApiKeyLength = \$apiKey.Length
#     Status = "Success"
# } | ConvertTo-Json
#
# Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
#     StatusCode = [HttpStatusCode]::OK
#     Body = \$body
# })
# EOF
#   filename = "${path.module}/function/run.ps1"
# }
#
# data "archive_file" "function_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/function"
#   output_path = "${path.module}/function.zip"
#
#   depends_on = [
#     local_file.test_function_json,
#     local_file.test_function_code
#   ]
# }
#
# resource "null_resource" "deploy_function_code" {
#   depends_on = [
#     azurerm_windows_function_app.func,
#     data.archive_file.function_zip
#   ]
#
#   provisioner "local-exec" {
#     command = <<EOT
# az functionapp deployment source config-zip \
#   --name ${azurerm_windows_function_app.func.name} \
#   --resource-group ${azurerm_windows_function_app.func.resource_group_name} \
#   --src ${data.archive_file.function_zip.output_path}
# EOT
#   }
# }

