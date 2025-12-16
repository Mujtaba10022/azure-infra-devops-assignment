resource "azurerm_key_vault" "main" {
  name                       = var.keyvault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var. sku_name
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = var.tags
}
