# Data source for existing resource group
data "azurerm_resource_group" "main" {
  name = "RG-GM_Assessment"
}

output "resource_group_name" {
  value = data.azurerm_resource_group.main. name
}

output "status" {
  value = "Infrastructure deployed - AKS created via Azure CLI"
}
