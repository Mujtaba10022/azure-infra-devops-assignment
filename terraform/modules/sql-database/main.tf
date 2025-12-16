data "azurerm_client_config" "current" {}

resource "azurerm_mssql_server" "main" {
  name                          = var.sql_server_name
  resource_group_name           = var. resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.admin_login
  administrator_login_password  = var.admin_password
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
 
  azuread_administrator {
    login_username              = "AzureAD Admin"
    object_id                   = data.azurerm_client_config.current.object_id
    azuread_authentication_only = false
  }
 
  tags = var.tags
}

resource "azurerm_mssql_database" "main" {
  name                 = var.sql_database_name
  server_id            = azurerm_mssql_server.main.id
  sku_name             = var. sku_name
  max_size_gb          = var.max_size_gb
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  zone_redundant       = false
  geo_backup_enabled   = var. geo_backup_enabled
  storage_account_type = var.geo_backup_enabled ? "Geo" : "Local"

  short_term_retention_policy {
    retention_days           = 7
    backup_interval_in_hours = 12
  }
 
  tags = var.tags
}

resource "azurerm_private_endpoint" "sql" {
  name                = "pe-${var.sql_server_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "psc-${var.sql_server_name}"
    private_connection_resource_id = azurerm_mssql_server.main. id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
 
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
