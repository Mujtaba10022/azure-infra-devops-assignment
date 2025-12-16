terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "RG-GM_Assessment"
    storage_account_name = "stgmstaging"
    container_name       = "tfstate"
    key                  = "staging.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
