# Azure OpenAI in DIFFERENT region (compliance)
resource "azurerm_cognitive_account" "openai" {
  name                          = var.openai_name
  location                      = var.openai_location
  resource_group_name           = var.resource_group_name
  kind                          = "OpenAI"
  sku_name                      = "S0"
  public_network_access_enabled = false
  custom_subdomain_name         = var.openai_name
 
  identity {
    type = "SystemAssigned"
  }

  network_acls {
    default_action = "Deny"
  }

  tags = var.tags
}

# Model Deployments
resource "azurerm_cognitive_deployment" "models" {
  for_each = var.deployments
 
  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.openai. id
 
  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each. value.model_version
  }

  scale {
    type     = "Standard"
    capacity = each.value.capacity
  }
}

# Private Endpoint (Cross-Region)
resource "azurerm_private_endpoint" "openai" {
  name                = "pe-${var.openai_name}"
  location            = var. aks_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "psc-${var.openai_name}"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }
 
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
