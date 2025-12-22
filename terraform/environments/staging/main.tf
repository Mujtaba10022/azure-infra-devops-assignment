# Staging Environment - Main Configuration
# Author:  Ghulam Mujtaba
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
    key                  = "staging. terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
data "azurerm_client_config" "current" {}

# =============================================================================
# LOG ANALYTICS WORKSPACE (Required for AKS monitoring)
# =============================================================================
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var. resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = { Environment = var.environment, Project = var. project }
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
}

# =============================================================================
# ACR MODULE
# =============================================================================
module "acr" {
  source              = "../../modules/acr"
  resource_group_name = var.resource_group_name
  location            = var. location
  acr_name            = "acr${var. project}${var. environment}"
  tags                = { Environment = var.environment, Project = var. project }
}

# =============================================================================
# AKS MODULE
# =============================================================================
module "aks" {
  source                     = "../../modules/aks"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  cluster_name               = "aks-${var.project}-${var.environment}"
  dns_prefix                 = "aks-${var.project}-${var.environment}"
  subnet_id                  = module.network. aks_subnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  system_node_count          = var. aks_node_count
  system_node_vm_size        = var.aks_vm_size
  acr_id                     = module. acr.acr_id
  attach_acr                 = true
  tags                       = { Environment = var.environment, Project = var. project }
}

# =============================================================================
# SQL DATABASE MODULE
# =============================================================================
module "sql" {
  source              = "../../modules/sql"
  resource_group_name = var.resource_group_name
  location            = var.location
  sql_location        = "westus2"
  environment         = var.environment
  project             = var.project
  admin_username      = var.sql_admin_username
  admin_password      = var.sql_admin_password
  subnet_id           = module.network.private_endpoints_subnet_id
  dns_zone_id         = module.network.dns_zone_sql_id
}

# =============================================================================
# KEY VAULT MODULE
# =============================================================================
module "keyvault" {
  source              = "../../modules/keyvault"
  resource_group_name = var.resource_group_name
  location            = var. location
  environment         = var.environment
  project             = var.project
  subnet_id           = module.network. private_endpoints_subnet_id
  dns_zone_id         = module.network. dns_zone_keyvault_id
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

# =============================================================================
# STORAGE MODULE
# =============================================================================
module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = var.resource_group_name
  location             = var. location
  storage_account_name = "st${var.project}${var.environment}"
  tags                 = { Environment = var.environment, Project = var. project }
}

# =============================================================================
# OPENAI MODULE
# =============================================================================
module "openai" {
  source              = "../../modules/openai"
  resource_group_name = var.resource_group_name
  location            = "westus"
  openai_name         = "oai-${var.project}-${var.environment}"
  tags                = { Environment = var.environment, Project = var.project }
}