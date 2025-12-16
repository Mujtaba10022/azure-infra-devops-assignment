data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  suffix = random_string.suffix.result
  tags = merge(var.tags, {
    Environment = var.environment
  })
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-${local.suffix}"
  location = var. aks_location
  tags     = local.tags
}
 
module "networking" {
  source              = "../../modules/networking"
  resource_group_name = azurerm_resource_group.main. name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  vnet_address_space  = ["10.0.0.0/16"]
  tags                = local.tags
}

module "keyvault" {
  source              = "../../modules/keyvault"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  keyvault_name       = "kv-${var.environment}-${local.suffix}"
  tenant_id           = data.azurerm_client_config.current. tenant_id
  pe_subnet_id        = module.networking.pe_subnet_id
  private_dns_zone_id = module.networking.dns_zone_ids["keyvault"]
  tags                = local.tags
  depends_on          = [module.networking]
}

module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  environment          = var.environment
  storage_account_name = "st${var.environment}${local.suffix}"
  pe_subnet_id         = module. networking.pe_subnet_id
  private_dns_zone_id  = module.networking.dns_zone_ids["storage"]
  tags                 = local.tags
  depends_on           = [module.networking]
}

module "sql_database" {
  source              = "../../modules/sql-database"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  sql_server_name     = "sql-${var.environment}-${local.suffix}"
  sql_database_name   = "sqldb-customerservice"
  admin_login         = var.sql_admin_login
  admin_password      = var.sql_admin_password
  pe_subnet_id        = module. networking.pe_subnet_id
  private_dns_zone_id = module.networking.dns_zone_ids["sql"]
  tags                = local. tags
  depends_on          = [module.networking]
}

module "acr" {
  source              = "../../modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  acr_name            = "acr${var.environment}${local.suffix}"
  pe_subnet_id        = module.networking.pe_subnet_id
  private_dns_zone_id = module.networking.dns_zone_ids["acr"]
  tags                = local. tags
  depends_on          = [module.networking]
}

module "openai" {
  source              = "../../modules/openai"
  resource_group_name = azurerm_resource_group.main.name
  openai_location     = var.openai_location
  aks_location        = var. aks_location
  environment         = var.environment
  openai_name         = "oai-${var.environment}-${local.suffix}"
  pe_subnet_id        = module. networking.pe_subnet_id
  private_dns_zone_id = module.networking.dns_zone_ids["openai"]
  tags                = local.tags
  depends_on          = [module.networking]
}

module "aks" {
  source              = "../../modules/aks"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  cluster_name        = "aks-${var.environment}-${local. suffix}"
  dns_prefix          = "aks-${var.environment}"
  kubernetes_version  = "1.28"
  aks_subnet_id       = module.networking. aks_subnet_id
  acr_id              = module.acr.acr_id
  tags                = local.tags
  depends_on          = [module. networking, module.acr]
}

resource "azurerm_role_assignment" "aks_keyvault" {
  scope                            = module.keyvault.keyvault_id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = module.aks.cluster_identity_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_key_vault_secret" "sql_connection" {
  name         = "sql-connection-string"
  value        = "Server=tcp:${module.sql_database.sql_server_fqdn},1433;Database=${module.sql_database.sql_database_name};"
  key_vault_id = module.keyvault.keyvault_id
  depends_on   = [module.keyvault]
}

resource "azurerm_key_vault_secret" "openai_key" {
  name         = "openai-api-key"
  value        = module.openai.openai_primary_key
  key_vault_id = module.keyvault.keyvault_id
  depends_on   = [module.keyvault, module.openai]
}
