output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = [for s in aws_subnet.public : s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }
output "alb_sg_id" { value = aws_security_group.alb_sg.id }
output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}
output "vpce_ids" {
  description = "Interface endpoint IDs by service"
  value       = { for k, ep in aws_vpc_endpoint.interface : k => ep.id }
}