resource "aws_secretsmanager_secret" "openai" {
  name = "openai-api-key"
}
resource "aws_secretsmanager_secret_version" "openai_v1" {
  secret_id     = aws_secretsmanager_secret.openai.id
  secret_string = var.openai_api_key
}

resource "aws_secretsmanager_secret" "openai_project_id" {
  name = "openai-project-id"
}
resource "aws_secretsmanager_secret_version" "openai_project_id_v1" {
  secret_id     = aws_secretsmanager_secret.openai_project_id.id
  secret_string = var.openai_project_id
}

resource "aws_secretsmanager_secret" "litellm_master_key" {
  name = "litellm-master-key"
}
resource "aws_secretsmanager_secret_version" "litellm_master_key_v1" {
  secret_id     = aws_secretsmanager_secret.litellm_master_key.id
  secret_string = var.LITELLM_MASTER_KEY
}

resource "aws_secretsmanager_secret" "database_url" {
  name = "litellm-database-url"
}
resource "aws_secretsmanager_secret_version" "database_url_v1" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = var.DATABASE_URL
}
