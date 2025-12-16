variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for AKS"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "acr_id" {
  description = "ACR ID for pull permissions"
  type        = string
  default     = ""
}

variable "system_node_count" {
  description = "System node pool count"
  type        = number
  default     = 2
}

variable "system_node_vm_size" {
  description = "System node VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "system_node_min_count" {
  description = "System node min count"
  type        = number
  default     = 2
}

variable "system_node_max_count" {
  description = "System node max count"
  type        = number
  default     = 5
}

variable "user_node_count" {
  description = "User node pool count"
  type        = number
  default     = 2
}

variable "user_node_vm_size" {
  description = "User node VM size"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "user_node_min_count" {
  description = "User node min count"
  type        = number
  default     = 2
}

variable "user_node_max_count" {
  description = "User node max count"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
