variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "cluster_name" { type = string }
variable "dns_prefix" { type = string }
variable "kubernetes_version" { type = string; default = "1.28" }
variable "subnet_id" { type = string }
variable "node_count" { type = number; default = 2 }
variable "node_vm_size" { type = string; default = "Standard_D2s_v3" }
variable "tags" { type = map(string); default = {} }
