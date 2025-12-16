# Data source for existing resource group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Data source for current client
data "azurerm_client_config" "current" {}

# Use existing Virtual Network
data "azurerm_virtual_network" "main" {
  name                = "vnet-gm-staging"
  resource_group_name = data.azurerm_resource_group.main.name
}

# Use existing subnet or create new one for AKS
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = data. azurerm_virtual_network. main.name
  address_prefixes     = ["10.0.4.0/22"]
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-gm-staging"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data. azurerm_resource_group. main.name
  dns_prefix          = "aks-gm-staging"
  kubernetes_version  = "1.28"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
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
  value = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}
