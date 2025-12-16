output "openai_id" {
  description = "OpenAI account ID"
  value       = azurerm_cognitive_account. openai.id
}

output "openai_name" {
  description = "OpenAI account name"
  value       = azurerm_cognitive_account.openai.name
}
 
output "openai_endpoint" {
  description = "OpenAI endpoint"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "openai_location" {
  description = "OpenAI location"
  value       = azurerm_cognitive_account.openai.location
}

output "openai_primary_key" {
  description = "OpenAI primary key"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}
