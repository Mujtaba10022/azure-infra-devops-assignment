output "resource_group_name" {
  description = "Resource group name"
  value       = data.azurerm_resource_group.main. name
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = module.aks.cluster_id
}

output "acr_name" {
  description = "ACR name"
  value       = module.acr.acr_name
}

output "acr_login_server" {
  description = "ACR login server"
  value       = module.acr. login_server
}

output "keyvault_name" {
  description = "Key Vault name"
  value       = module.keyvault.keyvault_name
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = module.keyvault.keyvault_uri
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module. storage.storage_account_name
}

output "sql_server_name" {
  description = "SQL Server name"
  value       = module.sql_database. server_name
}

output "sql_database_name" {
  description = "SQL Database name"
  value       = module.sql_database. database_name
}

output "vnet_id" {
  description = "VNet ID"
  value       = module.networking.vnet_id
}

output "aks_subnet_id" {
  description = "AKS subnet ID"
  value       = module.networking.aks_subnet_id
}
