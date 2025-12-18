# Staging Environment - Main Configuration
# Author: Ghulam Mujtaba
# Description: Production-grade Azure infrastructure with Private Endpoints

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
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
}

# =============================================================================
# NETWORKING MODULE
# =============================================================================
module "network" {
  source              = "../../modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
  vnet_address_space  = ["10.0.0.0/16"]
  aks_subnet_prefix   = "10.0.4.0/22"
  pe_subnet_prefix    = "10.0.2.0/24"
}

# =============================================================================
# AKS MODULE
# =============================================================================
module "aks" {
  source              = "../../modules/aks"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
  subnet_id           = module.network.aks_subnet_id
  node_count          = var.aks_node_count
  vm_size             = var.aks_vm_size
}

# =============================================================================
# ACR MODULE
# =============================================================================
module "acr" {
  source              = "../../modules/acr"
  resource_group_name = var.resource_group_name
  location            = var. location
  environment         = var. environment
  project             = var. project
}

# =============================================================================
# SQL DATABASE MODULE
# =============================================================================
module "sql" {
  source              = "../../modules/sql"
  resource_group_name = var.resource_group_name
  location            = "westus2"  # Different region for geo-compliance
  environment         = var.environment
  project             = var.project
  subnet_id           = module.network. pe_subnet_id
  admin_password      = var.sql_admin_password
}

# =============================================================================
# KEY VAULT MODULE
# =============================================================================
module "keyvault" {
  source              = "../../modules/keyvault"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
}

# =============================================================================
# STORAGE MODULE
# =============================================================================
module "storage" {
  source              = "../../modules/storage"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project
}

# =============================================================================
# OPENAI MODULE
# =============================================================================
module "openai" {
  source              = "../../modules/openai"
  resource_group_name = var.resource_group_name
  location            = "westus"  # OpenAI available region
  environment         = var.environment
  project             = var.project
}

# =============================================================================
# PRIVATE ENDPOINTS MODULE
# =============================================================================
module "private_endpoint_sql" {
  source              = "../../modules/private-endpoints"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  subnet_id           = module.network. pe_subnet_id
  resource_id         = module.sql.sql_server_id
  resource_type       = "sql"
  subresource_names   = ["sqlServer"]
}

module "private_endpoint_keyvault" {
  source              = "../../modules/private-endpoints"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  subnet_id           = module.network.pe_subnet_id
  resource_id         = module.keyvault. keyvault_id
  resource_type       = "keyvault"
  subresource_names   = ["vault"]
}

module "private_endpoint_storage" {
  source              = "../../modules/private-endpoints"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  subnet_id           = module. network.pe_subnet_id
  resource_id         = module. storage.storage_account_id
  resource_type       = "storage"
  subresource_names   = ["blob"]
}
