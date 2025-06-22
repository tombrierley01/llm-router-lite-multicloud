output "openai_secret_arn" {
  value = aws_secretsmanager_secret.openai.arn
}
output "openai_project_id_secret_arn" {
  value = aws_secretsmanager_secret.openai_project_id.arn
}
output "litellm_master_key_secret_arn" {
  value = aws_secretsmanager_secret.litellm_master_key.arn
}
output "database_url_secret_arn" {
  value = aws_secretsmanager_secret.database_url.arn
}
