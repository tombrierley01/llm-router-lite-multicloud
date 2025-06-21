variable "container_image" {
  description = "ECR URI for LiteLLM"
  type        = string
}

variable "openai_api_key" {
  description = "OpenAI key passed down to secrets module"
  type        = string
  sensitive   = true
}

variable "openai_project_id" {
  type        = string
  description = "OpenAI project ID"
}

variable "LITELLM_MASTER_KEY" {
  type      = string
  sensitive = true
}

variable "DATABASE_URL" {
  type      = string
  sensitive = true
}
