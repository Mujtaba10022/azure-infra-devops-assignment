variable "sql_location" {
  type        = string
  default     = ""
  description = "Location for SQL Server (defaults to var.location if not set)"
}

locals {
  sql_location = var.sql_location != "" ? var.sql_location : var. location
}

resource "azurerm_mssql_server" "main" {
  name                          = "sql-${var.project}-${var.environment}"
  resource_group_name           = var.resource_group_name
  location                      = local.sql_location
  version                       = "12.0"
  administrator_login           = var. admin_username
  administrator_login_password  = var.admin_password
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  tags = { Environment = var.environment, Project = var.project }
}

resource "azurerm_mssql_database" "main" {
  name               = "customerdb"
  server_id          = azurerm_mssql_server. main.id
  collation          = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb        = 2
  sku_name           = "Basic"
  geo_backup_enabled = true
  tags = { Environment = var.environment }
}

resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql-${var.environment}"
  location            = var.location
  resource_group_name = var. resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.dns_zone_id]
  }
}