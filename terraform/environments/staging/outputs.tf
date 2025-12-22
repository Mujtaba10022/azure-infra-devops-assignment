# Outputs for Staging Environment

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "acr_login_server" {
  description = "ACR login server"
  value       = module.acr. login_server
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = module.sql.sql_server_fqdn
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = module.keyvault.key_vault_uri
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.storage.storage_account_name
}
