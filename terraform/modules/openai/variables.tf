variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "openai_name" {
  description = "OpenAI service name"
  type        = string
}

variable "sku_name" {
  description = "OpenAI SKU"
  type        = string
  default     = "S0"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
