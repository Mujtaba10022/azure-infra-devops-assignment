output "server_id" {
  description = "SQL Server ID"
  value       = azurerm_mssql_server.main.id
}

output "server_name" {
  description = "SQL Server name"
  value       = azurerm_mssql_server.main.name
}

output "database_id" {
  description = "SQL Database ID"
  value       = azurerm_mssql_database.main. id
}

output "database_name" {
  description = "SQL Database name"
  value       = azurerm_mssql_database.main.name
}

output "fqdn" {
  description = "SQL Server FQDN"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}
