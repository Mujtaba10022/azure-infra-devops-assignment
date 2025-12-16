variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}
 
variable "openai_location" {
  description = "Azure region for OpenAI ^(MUST be different from AKS^)"
  type        = string
}
 
variable "aks_location" {
  description = "AKS region ^(for private endpoint^)"
  type        = string
}
 
variable "environment" {
  description = "Environment name"
  type        = string
}
 
variable "openai_name" {
  description = "Name of the OpenAI service"
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
 
variable "deployments" {
  description = "Map of model deployments"
  type = map(object({
    model_name    = string
    model_version = string
    capacity      = number
  }))
  default = {
    "gpt-4" = {
      model_name    = "gpt-4"
      model_version = "0613"
      capacity      = 10
    }
    "gpt-35-turbo" = {
      model_name    = "gpt-35-turbo"
      model_version = "0613"
      capacity      = 30
    }
  }
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
