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
  type        = string
  sensitive   = true
  description = "Auth key"
}

variable "DATABASE_URL" {
  type        = string
  sensitive   = true
  description = "RDS Connection"
}

variable "JWT_SECRET" {
  type        = string
  sensitive   = true
  description = "JWT for auth"
}