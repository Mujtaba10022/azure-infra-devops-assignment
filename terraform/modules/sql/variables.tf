variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type    = string
  default = "gm"
}

variable "subnet_id" {
  type = string
}

variable "dns_zone_id" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "sqladmin"
}

variable "admin_password" {
  type      = string
  sensitive = true
}