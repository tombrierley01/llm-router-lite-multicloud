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



resource "aws_iam_role_policy_attachment" "exec_logs" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/* Task role (app permissions) */
resource "aws_iam_role" "task" {
  name               = "litellm-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
}
