resource "aws_ecs_service" "this" {
  name            = "litellm-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets = var.private_subnet_ids
    security_groups = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.tg_arn
    container_name   = "litellm"
    container_port   = 8000
  }

  deployment_controller {
    type = "ECS"
  }

  depends_on = [aws_ecs_task_definition.this]
}