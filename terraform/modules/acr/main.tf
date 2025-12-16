resource "azurerm_container_registry" "main" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var. sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = false
 
  tags = var.tags
}

resource "azurerm_private_endpoint" "acr" {
  name                = "pe-${var.acr_name}"
  location            = var.location
  resource_group_name = var. resource_group_name
  subnet_id           = var.pe_subnet_id
 
  private_service_connection {
    name                           = "psc-${var.acr_name}"
    private_connection_resource_id = azurerm_container_registry.main. id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
 
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
