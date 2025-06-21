resource "aws_secretsmanager_secret" "openai" {
  name = "openai-api-key"
}

resource "aws_secretsmanager_secret_version" "openai_v1" {
  secret_id     = aws_secretsmanager_secret.openai.id
  secret_string = var.openai_api_key
}

output "openai_secret_arn" {
  value = aws_secretsmanager_secret.openai.arn
}