#!/bin/bash

# Script to clean up Azure resources from the Function App Secure Deployment project
# This script includes safeguards to confirm before deletion

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Azure Function App Secure Deployment - Resource Cleanup ===${NC}"
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

# Resource group name
RG_NAME="milestones-we-dev"

# Check if resource group exists
echo "Checking if resource group ${RG_NAME} exists..."
RG_EXISTS=$(az group exists --name ${RG_NAME})

if [ "$RG_EXISTS" = "false" ]; then
    echo -e "${YELLOW}Resource group ${RG_NAME} does not exist. Nothing to clean up.${NC}"
    exit 0
fi

# List all resources in the resource group
echo -e "${BLUE}Resources in resource group ${RG_NAME}:${NC}"
az resource list --resource-group ${RG_NAME} --query "[].{Name:name, Type:type}" -o table

# Confirm deletion
echo ""
echo -e "${RED}WARNING: This will delete ALL resources in the resource group ${RG_NAME}.${NC}"
echo -e "${RED}This action CANNOT be undone.${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo -e "${YELLOW}Cleanup canceled.${NC}"
    exit 0
fi

# Extra confirmation for safety
read -p "Please type the resource group name to confirm deletion: " CONFIRM_RG

if [[ "$CONFIRM_RG" != "$RG_NAME" ]]; then
    echo -e "${RED}Resource group name doesn't match. Cleanup canceled.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Deleting resource group ${RG_NAME}...${NC}"
echo -e "${YELLOW}This may take several minutes.${NC}"

# Delete the resource group
az group delete --name ${RG_NAME} --yes

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully initiated deletion of resource group ${RG_NAME}.${NC}"
    echo -e "${GREEN}Resources are being deleted in the background.${NC}"
else
    echo -e "${RED}Failed to delete resource group ${RG_NAME}.${NC}"
    exit 1
fi

# Option to check status
echo ""
echo -e "${BLUE}You can check the status of the deletion with:${NC}"
echo -e "  az group show --name ${RG_NAME}"
echo ""

# Check if there's a separate resource group for Terraform state
TFSTATE_RG="tfstate-rg"
TF_RG_EXISTS=$(az group exists --name ${TFSTATE_RG})

if [ "$TF_RG_EXISTS" = "true" ]; then
    echo -e "${YELLOW}Terraform state storage resource group ${TFSTATE_RG} also exists.${NC}"
    read -p "Do you want to delete this resource group as well? (yes/no): " DELETE_TFSTATE

    if [[ "$DELETE_TFSTATE" = "yes" ]]; then
        echo -e "${YELLOW}Deleting Terraform state resource group ${TFSTATE_RG}...${NC}"
        az group delete --name ${TFSTATE_RG} --yes

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successfully initiated deletion of resource group ${TFSTATE_RG}.${NC}"
        else
            echo -e "${RED}Failed to delete resource group ${TFSTATE_RG}.${NC}"
        fi
    else
        echo -e "${BLUE}Keeping Terraform state resource group ${TFSTATE_RG}.${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Cleanup process completed.${NC}"