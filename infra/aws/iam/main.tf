/* Execution role (pull image, write logs) */
resource "aws_iam_role" "task_exec" {
  name               = "litellm-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
}

data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = ["sts:AssumeRole"]
  principals {
  type        = "Service"
  identifiers = ["ecs-tasks.amazonaws.com"]
}
  }
}

/* Read from AWS Secrets */
###############################################################################
# Allow the execution role to read the four Secrets Manager entries
###############################################################################

data "aws_iam_policy_document" "exec_secrets" {
  statement {
    sid    = "ReadLiteLLMSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      var.openai_secret_arn,
      var.openai_project_id_secret_arn,
      var.litellm_master_key_secret_arn,
      var.database_url_secret_arn,
      var.jwt_secret_secret_arn
    ]
  }
}

resource "aws_iam_role_policy" "exec_secrets" {
  name   = "litellm-exec-read-secrets"
  role   = aws_iam_role.task_exec.id
  policy = data.aws_iam_policy_document.exec_secrets.json
}



resource "aws_iam_role_policy_attachment" "exec_logs" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/* Task role (app permissions) */
resource "aws_iam_role" "task" {
  name               = "litellm-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
}
