terraform {
  required_version = "^>= 1.5. 0"
 
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~^> 3.85.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~^> 3.6.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "REPLACE_WITH_YOUR_STORAGE"
    container_name       = "tfstate"
    key                  = "staging.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
