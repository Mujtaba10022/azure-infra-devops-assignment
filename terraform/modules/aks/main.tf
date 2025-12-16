# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "law-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var. tags
}
 
# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                    = var.cluster_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var. dns_prefix
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = true
 
  default_node_pool {
    name                         = "system"
    node_count                   = var.system_node_count
    vm_size                      = var.system_vm_size
    vnet_subnet_id               = var.aks_subnet_id
    type                         = "VirtualMachineScaleSets"
    only_critical_addons_enabled = true
    enable_auto_scaling          = var.enable_auto_scaling
    min_count                    = var.enable_auto_scaling ? var.min_node_count : null
    max_count                    = var.enable_auto_scaling ? var.max_node_count : null
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    service_cidr      = "10.100.0.0/16"
    dns_service_ip    = "10.100.0.10"
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }
 
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  tags = var.tags
 
  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

# User Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.user_vm_size
  vnet_subnet_id        = var.aks_subnet_id
  node_count            = var.user_node_count
  enable_auto_scaling   = var. enable_auto_scaling
  min_count             = var.enable_auto_scaling ? var.min_node_count : null
  max_count             = var.enable_auto_scaling ? (var.max_node_count * 2) : null
  mode                  = "User"
 
  node_labels = {
    "nodepool" = "user"
    "workload" = "applications"
  }
 
  tags = var.tags
 
  lifecycle {
    ignore_changes = [node_count]
  }
}

# ACR Pull permission
resource "azurerm_role_assignment" "acr_pull" {
  count                            = var.acr_id  0
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}
