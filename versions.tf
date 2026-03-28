terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Uncomment and fill in after creating the storage account for remote state
  # backend "azurerm" {
  #   resource_group_name  = "rg-wealthos-tfstate"
  #   storage_account_name = "stwealthostfstate"
  #   container_name       = "tfstate"
  #   key                  = "wealthos.tfstate"
  # }
}
