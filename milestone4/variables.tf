# Variables specific to Milestone 4

variable "vnet_address_space" {
  description = "Address space for the virtual network for the Function App"
  type        = string
  default     = "10.0.0.0/16"
}

variable "function_subnet_prefix" {
  description = "Address prefix for the Function App subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "webapp_vnet_address_space" {
  description = "Address space for the virtual network for the Web App"
  type        = string
  default     = "10.1.0.0/16"
}

variable "webapp_subnet_prefix" {
  description = "Address prefix for the Web App subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "webapp_name" {
  description = "Name of the Web App to create"
  type        = string
  default     = "webapp"
}

variable "webapp_sku" {
  description = "SKU for the Web App service plan"
  type        = string
  default     = "P1v2"
  validation {
    condition     = contains(["P1v2", "P2v2", "P3v2", "P1v3", "P2v3", "P3v3"], var.webapp_sku)
    error_message = "Web App SKU must be a premium tier (P1v2, P2v2, P3v2, P1v3, P2v3, P3v3) to support VNet integration."
  }
}

variable "function_app_sku" {
  description = "SKU for the Function App service plan"
  type        = string
  default     = "EP1"
  validation {
    condition     = contains(["EP1", "EP2", "EP3"], var.function_app_sku)
    error_message = "Function App SKU must be an Elastic Premium tier (EP1, EP2, EP3) to support VNet integration."
  }
}