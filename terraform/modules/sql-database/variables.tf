variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "server_name" {
  description = "SQL Server name"
  type        = string
}

variable "database_name" {
  description = "SQL Database name"
  type        = string
}

variable "admin_login" {
  description = "SQL admin login"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
