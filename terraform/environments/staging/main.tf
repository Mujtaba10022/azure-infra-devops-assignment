# Data source for existing resource group
data "azurerm_resource_group" "main" {
  name = "RG-GM_Assessment"
}

# Use existing Virtual Network
data "azurerm_virtual_network" "main" {
  name                = "vnet-gm-staging"
  resource_group_name = data.azurerm_resource_group.main.name
}

# Use existing AKS subnet
data "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-gm-staging"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = "aksgmstaging"
  kubernetes_version  = "1.27"

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "staging"
    Project     = "GM-Assessment"
    ManagedBy   = "Terraform"
  }
}

output "resource_group_name" {
  value = data.azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster. main.name
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}
