variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  sensitive   = true
}
variable "openai_project_id" {
  description = "OpenAI Project ID"
  type        = string
  sensitive   = true
}
variable "LITELLM_MASTER_KEY" {
  description = "LiteLLM Master Key"
  type        = string
  sensitive   = true
}
variable "DATABASE_URL" {
  description = "Database URL"
  type        = string
  sensitive   = true
}
