output "openai_id" {
  description = "OpenAI service ID"
  value       = azurerm_cognitive_account.openai.id
}

output "openai_name" {
  description = "OpenAI service name"
  value       = azurerm_cognitive_account.openai.name
}

output "openai_endpoint" {
  description = "OpenAI endpoint"
  value       = azurerm_cognitive_account.openai.endpoint
}
