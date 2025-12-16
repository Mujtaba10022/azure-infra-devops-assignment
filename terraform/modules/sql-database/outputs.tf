output "sql_server_id" {
  description = "SQL Server ID"
  value       = azurerm_mssql_server.main. id
}
 
output "sql_server_name" {
  description = "SQL Server name"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "SQL Database ID"
  value       = azurerm_mssql_database.main.id
}
 
output "sql_database_name" {
  description = "SQL Database name"
  value       = azurerm_mssql_database.main.name
}
