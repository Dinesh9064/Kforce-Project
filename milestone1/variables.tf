variable "resource_group_name" {
  description = "Base name of the resource group (will be combined with environment suffix)"
  type        = string
  default     = "func-secure-rg"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "westeurope" # ✅ changed from 'eastus' to match working region in main.tf
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "SecureFunctionApp"
    ManagedBy   = "Terraform"
    Owner       = "CloudTeam"
  }
}
