output "cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.main.name
}
 
output "cluster_fqdn" {
  description = "AKS cluster private FQDN"
  value       = azurerm_kubernetes_cluster.main.private_fqdn
}
 
output "kube_config_raw" {
  description = "Raw kube config"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Kubelet identity object ID"
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0]. object_id
}

output "kubelet_identity_client_id" {
  description = "Kubelet identity client ID"
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0]. client_id
}

output "cluster_identity_principal_id" {
  description = "Cluster identity principal ID"
  value       = azurerm_kubernetes_cluster.main. identity[0].principal_id
}

output "node_resource_group" {
  description = "Node resource group name"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}
