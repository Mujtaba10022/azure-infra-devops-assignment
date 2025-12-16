# Data source for existing resource group
data "azurerm_resource_group" "main" {
  name = var. resource_group_name
}

# Data source for current client
data "azurerm_client_config" "current" {}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.project_name}-${var.environment}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main. name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Networking Module
module "networking" {
  source              = "../../modules/networking"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  vnet_name           = "vnet-${var.project_name}-${var.environment}"
  vnet_address_space  = var.vnet_address_space
  aks_subnet_name     = "snet-aks-${var.project_name}-${var.environment}"
  aks_subnet_prefix   = var.aks_subnet_prefix
  pe_subnet_name      = "snet-pe-${var.project_name}-${var.environment}"
  pe_subnet_prefix    = var.pe_subnet_prefix
  appgw_subnet_name   = "snet-appgw-${var.project_name}-${var.environment}"
  appgw_subnet_prefix = var.appgw_subnet_prefix
  tags                = var.tags
}

# Azure Container Registry
module "acr" {
  source              = "../../modules/acr"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  acr_name            = "acr${var.project_name}${var.environment}"
  sku                 = "Premium"
  admin_enabled       = false
  tags                = var.tags
}

# Azure Kubernetes Service
module "aks" {
  source                      = "../../modules/aks"
  resource_group_name         = data.azurerm_resource_group.main.name
  location                    = data.azurerm_resource_group.main. location
  cluster_name                = "aks-${var.project_name}-${var.environment}"
  dns_prefix                  = "aks-${var.project_name}-${var.environment}"
  kubernetes_version          = var.kubernetes_version
  subnet_id                   = module.networking.aks_subnet_id
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.main.id
  acr_id                      = module. acr.acr_id
  system_node_count           = 2
  system_node_vm_size         = "Standard_D2s_v3"
  system_node_min_count       = 2
  system_node_max_count       = 5
  user_node_count             = 2
  user_node_vm_size           = "Standard_D4s_v3"
  user_node_min_count         = 2
  user_node_max_count         = 10
  tags                        = var. tags
}

# Key Vault
module "keyvault" {
  source              = "../../modules/keyvault"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  keyvault_name       = "kv-${var.project_name}-${var.environment}"
  tenant_id           = data.azurerm_client_config.current. tenant_id
  sku_name            = "standard"
  tags                = var.tags
}

# Storage Account
module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = data.azurerm_resource_group.main.name
  location             = data.azurerm_resource_group.main.location
  storage_account_name = "st${var.project_name}${var.environment}"
  account_tier         = "Standard"
  replication_type     = "LRS"
  tags                 = var.tags
}

# SQL Database
module "sql_database" {
  source              = "../../modules/sql-database"
  resource_group_name = data. azurerm_resource_group. main.name
  location            = data.azurerm_resource_group.main.location
  server_name         = "sql-${var.project_name}-${var.environment}"
  database_name       = "sqldb-${var.project_name}-${var.environment}"
  admin_login         = var.sql_admin_login
  admin_password      = var.sql_admin_password
  tags                = var. tags
}

# Azure OpenAI (West US for compliance)
module "openai" {
  source              = "../../modules/openai"
  resource_group_name = data.azurerm_resource_group.main. name
  location            = var.location_secondary
  openai_name         = "oai-${var.project_name}-${var.environment}"
  sku_name            = "S0"
  tags                = var. tags
}

# Trigger CI/CD

# CI trigger

# Fix CI

# trigger

# trigger
