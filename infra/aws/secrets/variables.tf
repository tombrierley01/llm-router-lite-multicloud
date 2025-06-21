variable "openai_api_key" {
  description = "OpenAI API key to store in Secrets Manager"
  type        = string
  sensitive   = true
}
