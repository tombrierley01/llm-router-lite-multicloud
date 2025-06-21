resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/litellm"
  retention_in_days = 14
}
output "log_group_name" { value = aws_cloudwatch_log_group.ecs.name }
