output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main. name
}
 
output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "aks_location" {
  description = "AKS location"
  value       = azurerm_resource_group.main.location
}
 
output "acr_login_server" {
  description = "ACR login server"
  value       = module.acr.acr_login_server
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = module.acr.acr_admin_username
}

output "keyvault_name" {
  description = "Key Vault name"
  value       = module.keyvault. keyvault_name
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = module.sql_database.sql_server_fqdn
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module. storage.storage_account_name
}

output "openai_endpoint" {
  description = "OpenAI endpoint"
  value       = module.openai. openai_endpoint
}

output "openai_location" {
  description = "OpenAI location"
  value       = module.openai. openai_location
}

output "compliance_check" {
  description = "Compliance validation"
  value       = "AKS Region:  ${azurerm_resource_group.main.location} ^| OpenAI Region: ${module.openai.openai_location}"
}
