terraform {
  backend "azurerm" {
    resource_group_name  = "tf-backend-rg"
    storage_account_name = "tfstateopskart123"
    container_name       = "tfstate"
    key                  = "milestone1.terraform.tfstate"
  }
}
