variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_name" {
  description = "VNet name"
  type        = string
}

variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
}

variable "aks_subnet_name" {
  description = "AKS subnet name"
  type        = string
}

variable "aks_subnet_prefix" {
  description = "AKS subnet prefix"
  type        = list(string)
}

variable "pe_subnet_name" {
  description = "Private endpoint subnet name"
  type        = string
}

variable "pe_subnet_prefix" {
  description = "Private endpoint subnet prefix"
  type        = list(string)
}

variable "appgw_subnet_name" {
  description = "Application Gateway subnet name"
  type        = string
}

variable "appgw_subnet_prefix" {
  description = "Application Gateway subnet prefix"
  type        = list(string)
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
