locals {
  image = var.container_image != "" ? var.container_image : "211125430714.dkr.ecr.eu-west-2.amazonaws.com/litellm-router"
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
      image = local.image,
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "litellm-service"
  cluster         = aws_ecs_cluster.this.id 
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 2

  network_configuration {
    subnets = var.private_subnet_ids
    security_groups = [var.ecs_sg_id]
  }
  depends_on = [aws_lb_listener.this]
}


resource "aws_lb_listener" "this" {
  load_balancer_arn = var.alb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}
