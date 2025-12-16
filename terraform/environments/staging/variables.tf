variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
  default     = "RG-GM_Assessment"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}
