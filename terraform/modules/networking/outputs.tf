output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}
 
output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}
 
output "pe_subnet_id" {
  description = "ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "appgw_subnet_id" {
  description = "ID of the application gateway subnet"
  value       = azurerm_subnet.appgw.id
}

output "dns_zone_ids" {
  description = "Map of private DNS zone IDs"
  value = {
    sql      = azurerm_private_dns_zone.sql.id
    keyvault = azurerm_private_dns_zone.keyvault.id
    storage  = azurerm_private_dns_zone.storage_blob.id
    acr      = azurerm_private_dns_zone.acr.id
    openai   = azurerm_private_dns_zone.openai.id
  }
}
