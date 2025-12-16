variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "location" {
  description = "Primary Azure region"
  type        = string
  default     = "eastus"
}

variable "location_secondary" {
  description = "Secondary Azure region for OpenAI"
  type        = string
  default     = "westus"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "RG-GM_Assessment"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "gm"
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default = {
    Environment = "staging"
    Project     = "GM-Assessment"
    ManagedBy   = "Terraform"
    Owner       = "Ghulam-Mujtaba"
  }
}

variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_prefix" {
  description = "AKS subnet prefix"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "pe_subnet_prefix" {
  description = "Private endpoint subnet prefix"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "appgw_subnet_prefix" {
  description = "Application Gateway subnet prefix"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28. 3"
}

variable "sql_admin_login" {
  description = "SQL Server admin login"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}
