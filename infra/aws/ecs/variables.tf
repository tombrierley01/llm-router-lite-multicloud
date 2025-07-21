variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "task_exec_role_arn" { type = string }
variable "task_role_arn" { type = string }
variable "log_group_name" { type = string }
variable "tg_arn" { type = string }
variable "container_image" {
  description = "ECR URI for LiteLLM"
  type        = string
  default     = ""
}
variable "ecs_sg_id" {
  description = "Security Group ID for ECS service"
  type        = string
}
variable "openai_secret_arn" {
  type = string
}
variable "openai_project_id_secret_arn" {
  type = string
}
variable "litellm_master_key_secret_arn" {
  type = string
}
variable "database_url_secret_arn" {
  type = string
}
variable "jwt_secret_secret_arn" {
  type = string
}

