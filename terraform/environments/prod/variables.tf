variable "resource_group_name" { default = "RG-GM-Prod" }
variable "location" { default = "eastus" }
variable "environment" { default = "prod" }
variable "project" { default = "gm" }
variable "aks_node_count" { default = 3 }
variable "aks_vm_size" { default = "Standard_D2s_v3" }
