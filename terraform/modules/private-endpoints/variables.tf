variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "subnet_id" { type = string }
variable "resource_id" { type = string }
variable "resource_type" { type = string }
variable "subresource_names" { type = list(string) }
variable "dns_zone_id" { type = string }
