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
 
variable "sql_server_name" {
  description = "Name of the SQL server"
  type        = string
}

variable "sql_database_name" {
  description = "Name of the SQL database"
  type        = string
}

variable "admin_login" {
  description = "SQL admin username"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}
 
variable "pe_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}
 
variable "private_dns_zone_id" {
  description = "Private DNS zone ID"
  type        = string
}

variable "sku_name" {
  description = "SKU name"
  type        = string
  default     = "S1"
}
 
variable "max_size_gb" {
  description = "Max size in GB"
  type        = number
  default     = 32
}

variable "geo_backup_enabled" {
  description = "Enable geo backups"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
