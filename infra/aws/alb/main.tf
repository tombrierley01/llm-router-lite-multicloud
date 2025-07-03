variable "vpc_id"            { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "alb_sg_id"         { type = string }

resource "aws_lb" "this" {
  name               = "litellm-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "tg" {
  name        = "litellm-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/v1/models"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "target_group_arn" { value = aws_lb_target_group.tg.arn }
output "alb_dns"          { value = aws_lb.this.dns_name }
