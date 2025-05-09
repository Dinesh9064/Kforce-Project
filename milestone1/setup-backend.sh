#!/bin/bash

# Script to set up Terraform backend in Azure Storage Account
# This script creates the required resources for storing Terraform state

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP_NAME="tfstate-rg"
STORAGE_ACCOUNT_NAME="tfstateq0m19cdw"
CONTAINER_NAME="tfstate"
LOCATION="westeurope"

echo -e "${BLUE}=== Setting up Terraform Backend in Azure ===${NC}"
echo ""
echo -e "${BLUE}Resource Group:${NC} $RESOURCE_GROUP_NAME"
echo -e "${BLUE}Storage Account:${NC} $STORAGE_ACCOUNT_NAME"
echo -e "${BLUE}Container:${NC} $CONTAINER_NAME"
echo -e "${BLUE}Location:${NC} $LOCATION"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged in to Azure
echo "Checking Azure login status..."
az account show &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}You are not logged in to Azure. Please log in now.${NC}"
    az login
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to log in to Azure. Exiting.${NC}"
        exit 1
    fi
fi

# Get current subscription
SUBSCRIPTION=$(az account show --query name -o tsv)
echo -e "${GREEN}Using subscription: ${SUBSCRIPTION}${NC}"
echo ""

# Create resource group if it doesn't exist
echo "Checking if resource group exists..."
if ! az group show --name $RESOURCE_GROUP_NAME &> /dev/null; then
    echo -e "${YELLOW}Creating resource group ${RESOURCE_GROUP_NAME}...${NC}"
    az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create resource group. Exiting.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Resource group created successfully.${NC}"
else
    echo -e "${GREEN}Resource group ${RESOURCE_GROUP_NAME} already exists.${NC}"
fi

# Create storage account if it doesn't exist
echo "Checking if storage account exists..."
if ! az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME &> /dev/null; then
    echo -e "${YELLOW}Creating storage account ${STORAGE_ACCOUNT_NAME}...${NC}"
    az storage account create \
        --name $STORAGE_ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --location $LOCATION \
        --sku Standard_LRS \
        --kind StorageV2 \
        --encryption-services blob \
        --allow-blob-public-access false \
        --min-tls-version TLS1_2

    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create storage account. Exiting.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Storage account created successfully.${NC}"
else
    echo -e "${GREEN}Storage account ${STORAGE_ACCOUNT_NAME} already exists.${NC}"
fi

# Get storage account key
echo "Getting storage account key..."
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
if [ -z "$ACCOUNT_KEY" ]; then
    echo -e "${RED}Failed to get storage account key. Exiting.${NC}"
    exit 1
fi

# Create container if it doesn't exist
echo "Checking if container exists..."
CONTAINER_EXISTS=$(az storage container exists --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY --query exists -o tsv)
if [ "$CONTAINER_EXISTS" = "false" ]; then
    echo -e "${YELLOW}Creating container ${CONTAINER_NAME}...${NC}"
    az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create container. Exiting.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Container created successfully.${NC}"
else
    echo -e "${GREEN}Container ${CONTAINER_NAME} already exists.${NC}"
fi

# Create backend.conf file
echo "Creating backend.conf file..."
cat > backend.conf << EOF
storage_account_name = "$STORAGE_ACCOUNT_NAME"
container_name       = "$CONTAINER_NAME"
resource_group_name  = "$RESOURCE_GROUP_NAME"
EOF

echo -e "${GREEN}backend.conf file created successfully.${NC}"

# Create provider.tf file if it doesn't exist
if [ ! -f "provider.tf" ]; then
    echo "Creating provider.tf file..."
    cat > provider.tf << EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    # Backend configuration is provided in the backend.conf file
  }
}

provider "azurerm" {
  features {}
}
EOF
    echo -e "${GREEN}provider.tf file created successfully.${NC}"
fi

echo ""
echo -e "${BLUE}=== Terraform Backend Setup Complete ===${NC}"
echo ""
echo -e "${YELLOW}To initialize Terraform with this backend, use:${NC}"
echo -e "terraform init -backend-config=backend.conf"
echo ""
echo -e "${YELLOW}You may need to specify a key for each state file:${NC}"
echo -e "terraform init -backend-config=backend.conf -backend-config=\"key=milestone1.tfstate\""
echo ""