variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "aks_location" {
  description = "Azure region for AKS"
  type        = string
  default     = "eastus"
}
 
variable "openai_location" {
  description = "Azure region for OpenAI ^(MUST be different^)"
  type        = string
  default     = "westus"
}

variable "sql_admin_login" {
  description = "SQL admin username"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Default tags"
  type        = map(string)
  default = {
    Environment = "staging"
    Project     = "customer-service-portal"
    ManagedBy   = "terraform"
  }
}
