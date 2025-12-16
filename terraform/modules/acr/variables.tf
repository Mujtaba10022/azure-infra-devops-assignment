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

variable "acr_name" {
  description = "Name of the container registry"
  type        = string
}
 
variable "pe_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}
 
variable "private_dns_zone_id" {
  description = "Private DNS zone ID"
  type        = string
}

variable "sku" {
  description = "SKU ^(must be Premium for private endpoints^)"
  type        = string
  default     = "Premium"
}
 
variable "admin_enabled" {
  description = "Enable admin user"
  type        = bool
  default     = true
}
 
variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
