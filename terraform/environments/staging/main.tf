# Data source for existing resource group
data "azurerm_resource_group" "main" {
  name = var.  resource_group_name
}

# Data source for current client  
data "azurerm_client_config" "current" {}

# Note: Resources already exist in Azure - managed outside Terraform state
# The following resources were created: 
# - acrgmstaging (Container Registry)
# - kv-gm-staging (Key Vault)  
# - log-gm-staging (Log Analytics)
# - oai-gm-staging (OpenAI)
# - stgmstaging (Storage Account)
# - vnet-gm-staging (Virtual Network)
# - nsg-aks-eastus (Network Security Group)

output "resource_group_name" {
  value = data.azurerm_resource_group.main. name
}

output "resource_group_location" {
  value = data. azurerm_resource_group. main.location
}
