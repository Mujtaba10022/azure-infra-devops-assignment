variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}
 
variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}
 
variable "aks_subnet_id" {
  description = "Subnet ID for AKS nodes"
  type        = string
}

variable "system_node_count" {
  description = "Number of system nodes"
  type        = number
  default     = 2
}

variable "system_vm_size" {
  description = "VM size for system nodes"
  type        = string
  default     = "Standard_D2s_v3"
}
 
variable "user_node_count" {
  description = "Number of user nodes"
  type        = number
  default     = 2
}

variable "user_vm_size" {
  description = "VM size for user nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = true
}

variable "min_node_count" {
  description = "Minimum node count"
  type        = number
  default     = 1
}
 
variable "max_node_count" {
  description = "Maximum node count"
  type        = number
  default     = 5
}

variable "acr_id" {
  description = "ACR ID for pull permissions"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
