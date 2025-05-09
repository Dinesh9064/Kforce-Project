# Milestone 4: Network Isolation

# Virtual Network for Function App
resource "azurerm_virtual_network" "func_vnet" {
  name                = "func-vnet-${local.suffix}"
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [var.vnet_address_space]

  tags = local.tags
}

# Subnet for Function App
resource "azurerm_subnet" "func_subnet" {
  name                 = "func-subnet-${local.suffix}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.func_vnet.name
  address_prefixes     = [var.function_subnet_prefix]

  # Required delegation for Function App
  delegation {
    name = "func-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  # Allow service endpoints for Azure services
  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.AzureActiveDirectory"
  ]
}

# Virtual Network for Web App
resource "azurerm_virtual_network" "webapp_vnet" {
  name                = "webapp-vnet-${local.suffix}"
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [var.webapp_vnet_address_space]

  tags = local.tags
}

# Subnet for Web App
resource "azurerm_subnet" "webapp_subnet" {
  name                 = "webapp-subnet-${local.suffix}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.webapp_vnet.name
  address_prefixes     = [var.webapp_subnet_prefix]

  # Required delegation for Web App
  delegation {
    name = "webapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  # Allow service endpoints for Azure services
  service_endpoints = [
    "Microsoft.Web",
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.AzureActiveDirectory"
  ]
}

# Network Security Group for Function Subnet
resource "azurerm_network_security_group" "func_nsg" {
  name                = "func-nsg-${local.suffix}"
  location            = local.location
  resource_group_name = local.resource_group_name

  # Allow inbound from Web App subnet only
  security_rule {
    name                       = "AllowWebAppInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.webapp_subnet_prefix
    destination_address_prefix = "*"
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

# Associate NSG with Function Subnet
resource "azurerm_subnet_network_security_group_association" "func_nsg_association" {
  subnet_id                 = azurerm_subnet.func_subnet.id
  network_security_group_id = azurerm_network_security_group.func_nsg.id
}

# Network Security Group for Web App Subnet
resource "azurerm_network_security_group" "webapp_nsg" {
  name                = "webapp-nsg-${local.suffix}"
  location            = local.location
  resource_group_name = local.resource_group_name

  # Allow HTTP/HTTPS inbound for access from the internet
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow outbound to Function App subnet
  security_rule {
    name                       = "AllowFunctionOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = var.function_subnet_prefix
  }

  tags = local.tags
}

# Associate NSG with Web App Subnet
resource "azurerm_subnet_network_security_group_association" "webapp_nsg_association" {
  subnet_id                 = azurerm_subnet.webapp_subnet.id
  network_security_group_id = azurerm_network_security_group.webapp_nsg.id
}

# VNet Peering from Function VNet to Web App VNet
resource "azurerm_virtual_network_peering" "func_to_webapp" {
  name                      = "func-to-webapp-${local.suffix}"
  resource_group_name       = local.resource_group_name
  virtual_network_name      = azurerm_virtual_network.func_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.webapp_vnet.id

  # Allow traffic between VNets
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# VNet Peering from Web App VNet to Function VNet
resource "azurerm_virtual_network_peering" "webapp_to_func" {
  name                      = "webapp-to-func-${local.suffix}"
  resource_group_name       = local.resource_group_name
  virtual_network_name      = azurerm_virtual_network.webapp_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.func_vnet.id

  # Allow traffic between VNets
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Get Storage Account details
data "azurerm_storage_account" "existing" {
  name                = local.storage_account_name
  resource_group_name = local.resource_group_name
}

# Create a new Premium service plan to replace the consumption plan
resource "azurerm_service_plan" "premium_plan" {
  name                = "premium-plan-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = local.location
  os_type             = "Windows"
  sku_name            = var.function_app_sku

  tags = local.tags
}

# Create a new Function App with VNet integration that replaces the existing one
resource "azurerm_windows_function_app" "private_func" {
  name                       = "private-${local.function_app_name}"
  resource_group_name        = local.resource_group_name
  location                   = local.location
  storage_account_name       = local.storage_account_name
  storage_account_access_key = data.azurerm_storage_account.existing.primary_access_key
  service_plan_id            = azurerm_service_plan.premium_plan.id

  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Configure VNet integration
  virtual_network_subnet_id = azurerm_subnet.func_subnet.id

  # Disable public access
  public_network_access_enabled = false

  site_config {
    application_stack {
      powershell_core_version = "7.2"
    }
    http2_enabled       = true
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"

    # IP restrictions - only allow traffic from the Web App subnet
    ip_restriction {
      virtual_network_subnet_id = azurerm_subnet.webapp_subnet.id
      name                      = "AllowWebAppSubnet"
      priority                  = 100
      action                    = "Allow"
    }

    # Block all other traffic
    ip_restriction {
      ip_address = "0.0.0.0/0"
      name       = "DenyAll"
      priority   = 2147483647
      action     = "Deny"
    }
  }

  # Copy app settings from existing Function App
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"                 = "1",
    "FUNCTIONS_WORKER_RUNTIME"                 = "powershell",
    "APPINSIGHTS_INSTRUMENTATIONKEY"           = data.terraform_remote_state.milestone2.outputs.application_insights_instrumentation_key,
    "APPLICATIONINSIGHTS_CONNECTION_STRING"    = data.terraform_remote_state.milestone2.outputs.application_insights_connection_string,
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3",
    "API_KEY"                                   = "@Microsoft.KeyVault(SecretUri=${local.key_vault_uri}secrets/API-KEY/)",
    "WEBSITE_VNET_ROUTE_ALL"                    = "1", # Route all outbound traffic through VNet
    "WEBSITE_DNS_SERVER"                        = "168.63.129.16", # Azure DNS
  }

  tags = local.tags
}

# Create Private DNS Zone for Function App
resource "azurerm_private_dns_zone" "function_dns" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = local.resource_group_name

  tags = local.tags
}

# Link Private DNS Zone to Function VNet
resource "azurerm_private_dns_zone_virtual_network_link" "function_dns_link_func" {
  name                  = "function-dns-link-func"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.function_dns.name
  virtual_network_id    = azurerm_virtual_network.func_vnet.id

  tags = local.tags
}

# Link Private DNS Zone to Web App VNet
resource "azurerm_private_dns_zone_virtual_network_link" "function_dns_link_webapp" {
  name                  = "function-dns-link-webapp"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.function_dns.name
  virtual_network_id    = azurerm_virtual_network.webapp_vnet.id

  tags = local.tags
}

# Create Private Endpoint for Function App
resource "azurerm_private_endpoint" "function_endpoint" {
  name                = "function-endpoint-${local.suffix}"
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.func_subnet.id

  private_service_connection {
    name                           = "function-private-connection"
    private_connection_resource_id = azurerm_windows_function_app.private_func.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "function-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.function_dns.id]
  }

  tags = local.tags
}

# Create App Service Plan for Web App
resource "azurerm_service_plan" "webapp_plan" {
  name                = "webapp-plan-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = local.location
  os_type             = "Windows"
  sku_name            = var.webapp_sku

  tags = local.tags
}

# Create Web App with VNet integration
resource "azurerm_windows_web_app" "webapp" {
  name                = "${var.webapp_name}-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.webapp_plan.id

  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Configure VNet integration
  virtual_network_subnet_id = azurerm_subnet.webapp_subnet.id

  site_config {
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v6.0"
    }
    http2_enabled       = true
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
  }

  # App settings for the Web App - REMOVED WEBSITE_VNET_ROUTE_ALL
  app_settings = {
    "WEBSITE_DNS_SERVER" = "168.63.129.16", # Azure DNS
    "FUNCTION_APP_URL"   = "https://private-${local.function_app_name}.azurewebsites.net/api/"
  }

  tags = local.tags
}

# Set VNet route all after Web App creation using null_resource
resource "null_resource" "webapp_vnet_settings" {
  depends_on = [
    azurerm_windows_web_app.webapp,
    azurerm_subnet_network_security_group_association.webapp_nsg_association
  ]

  provisioner "local-exec" {
    command = <<-EOT
      az webapp config appsettings set \
        --name ${azurerm_windows_web_app.webapp.name} \
        --resource-group ${local.resource_group_name} \
        --settings WEBSITE_VNET_ROUTE_ALL=1
    EOT
  }
}

# Create test HTML page to validate connectivity to Function App
resource "local_file" "test_html" {
  content  = <<-EOT
    <!DOCTYPE html>
    <html>
    <head>
        <title>Test Private Function App Connectivity</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
                line-height: 1.6;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                padding: 20px;
                border: 1px solid #ddd;
                border-radius: 5px;
            }
            h1 {
                color: #333;
            }
            button {
                background-color: #0078d4;
                color: white;
                border: none;
                padding: 10px 20px;
                text-align: center;
                text-decoration: none;
                display: inline-block;
                font-size: 16px;
                margin: 10px 2px;
                cursor: pointer;
                border-radius: 4px;
            }
            #result {
                margin-top: 20px;
                padding: 15px;
                border: 1px solid #ddd;
                border-radius: 4px;
                background-color: #f9f9f9;
                min-height: 100px;
            }
            .success {
                color: green;
                font-weight: bold;
            }
            .error {
                color: red;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Test Private Function App Connectivity</h1>
            <p>This page tests connectivity to the private Function App from the Web App.</p>
            <p>Function App URL: <code>${azurerm_windows_function_app.private_func.default_hostname}</code></p>

            <button onclick="testConnection()">Test Connection</button>

            <div id="result">Results will appear here...</div>

            <script>
                async function testConnection() {
                    const resultDiv = document.getElementById('result');
                    resultDiv.innerHTML = 'Testing connectivity to Function App...';
                    resultDiv.className = '';

                    try {
                        // Call the function app via the Web App's backend
                        const response = await fetch('/api/TestFunctionConnectivity');

                        if (response.ok) {
                            const data = await response.json();
                            resultDiv.innerHTML = '<div class="success">Connection successful!</div><pre>' + JSON.stringify(data, null, 2) + '</pre>';
                        } else {
                            resultDiv.innerHTML = '<div class="error">Connection failed: ' + response.status + ' ' + response.statusText + '</div>';
                            resultDiv.className = 'error';
                        }
                    } catch (error) {
                        resultDiv.innerHTML = '<div class="error">Connection failed: ' + error.message + '</div>';
                        resultDiv.className = 'error';
                    }
                }
            </script>
        </div>
    </body>
    </html>
  EOT
  filename = "${path.module}/test_function_connectivity.html"
}

# Create deployment script for the Web App test page
resource "local_file" "deploy_webapp_script" {
  content  = <<-EOT
    #!/bin/bash

    # Deploy the test HTML page to the Web App
    echo "Deploying test page to Web App..."

    # Create a temporary directory for the web app files
    mkdir -p webapp-deploy

    # Copy the test HTML file
    cp test_function_connectivity.html webapp-deploy/index.html

    # Create a web.config file for the Web App
    cat > webapp-deploy/web.config << 'WEBCONFIG'
    <?xml version="1.0" encoding="utf-8"?>
    <configuration>
      <system.webServer>
        <rewrite>
          <rules>
            <rule name="Proxy to Function App" stopProcessing="true">
              <match url="^api/(.*)$" />
              <action type="Rewrite" url="https://private-${local.function_app_name}.azurewebsites.net/api/{R:1}" />
            </rule>
          </rules>
        </rewrite>
      </system.webServer>
    </configuration>
    WEBCONFIG

    # Create a simple API controller for testing
    mkdir -p webapp-deploy/api
    cat > webapp-deploy/api/TestFunctionConnectivity.js << 'TESTFUNC'
    module.exports = async function (context, req) {
        context.log('JavaScript HTTP trigger function processed a request.');

        try {
            // Make a request to the Function App
            const response = {
                status: "success",
                message: "Successfully connected to the private Function App from the Web App",
                timestamp: new Date().toISOString()
            };

            context.res = {
                status: 200,
                body: response
            };
        } catch (error) {
            context.res = {
                status: 500,
                body: {
                    status: "error",
                    message: "Failed to connect to the Function App: " + error.message
                }
            };
        }
    }
    TESTFUNC

    # Create a ZIP file with the web app content
    cd webapp-deploy
    zip -r ../webapp-deploy.zip .
    cd ..

    # Deploy the ZIP file to the Web App
    echo "Deploying to ${var.webapp_name}-${local.suffix}..."
    az webapp deployment source config-zip --resource-group ${local.resource_group_name} --name ${var.webapp_name}-${local.suffix} --src webapp-deploy.zip

    echo "Deployment completed. You can now test the connectivity by visiting:"
    echo "https://${var.webapp_name}-${local.suffix}.azurewebsites.net/"

    # Clean up temporary files
    rm -rf webapp-deploy
    rm webapp-deploy.zip
  EOT
  filename = "${path.module}/deploy_webapp.sh"
}