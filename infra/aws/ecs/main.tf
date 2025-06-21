locals {
  image = var.container_image != "" ? var.container_image : "ghcr.io/berriai/litellm:main-latest"
}

resource "aws_ecs_cluster" "this" { name = "litellm-cluster" }

resource "aws_ecs_task_definition" "this" {
  family                   = "litellm-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = var.task_exec_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "litellm"
      image = local.image
      portMappings = [{ containerPort = 4000, protocol = "tcp" }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "litellm"
        }
      }

      secrets = [{
        name      = "OPENAI_API_KEY"
        valueFrom = var.openai_secret_arn
      }]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "litellm-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false
    security_groups = [var.ecs_sg_id]
    subnets          = var.private_subnet_ids
  }

  load_balancer {
    target_group_arn = var.tg_arn
    container_name   = "litellm"
    container_port   = 4000
  }
}
