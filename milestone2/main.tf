# Milestone 2: Monitoring Configuration

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "func-law-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = local.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days

  tags = local.tags
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "func-ai-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = local.location
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
  sampling_percentage = var.app_insights_sampling_percentage

  tags = local.tags
}

# Diagnostic Settings for Log Analytics
resource "azurerm_monitor_diagnostic_setting" "law_diag" {
  name                       = "law-diag-settings"
  target_resource_id         = azurerm_log_analytics_workspace.law.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "Audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic settings for Function App
resource "azurerm_monitor_diagnostic_setting" "func_app_diag" {
  name                       = "func-diag-settings"
  target_resource_id         = local.function_app_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "FunctionAppLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "key_vault_diag" {
  name                       = "kv-diag-settings"
  target_resource_id         = local.key_vault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Diagnostic settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "storage_diag" {
  name                       = "sa-diag-settings"
  target_resource_id         = local.storage_account_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "Transaction"
    enabled  = true
  }

  metric {
    category = "Capacity"
    enabled  = true
  }
}

# Update Function App settings with Application Insights
resource "null_resource" "update_function_app_settings" {
  depends_on = [
    azurerm_application_insights.app_insights
  ]

  provisioner "local-exec" {
    command = <<EOT
az functionapp config appsettings set \
  --name ${local.function_app_name} \
  --resource-group ${local.resource_group_name} \
  --settings \
  "APPINSIGHTS_INSTRUMENTATIONKEY=${azurerm_application_insights.app_insights.instrumentation_key}" \
  "APPLICATIONINSIGHTS_CONNECTION_STRING=${azurerm_application_insights.app_insights.connection_string}" \
  "ApplicationInsightsAgent_EXTENSION_VERSION=~3"
EOT
  }
}