locals {
  # -------- interface endpoints we need ----------
  interface_endpoints = {
    secretsmanager = "com.amazonaws.${var.aws_region}.secretsmanager"
    ecr_api        = "com.amazonaws.${var.aws_region}.ecr.api"
    ecr_dkr        = "com.amazonaws.${var.aws_region}.ecr.dkr"
    logs           = "com.amazonaws.${var.aws_region}.logs"
    sts            = "com.amazonaws.${var.aws_region}.sts"
  }
}

########################
# SG for the endpoints #
########################
resource "aws_security_group" "vpce_sg" {
  name        = "vpce-sg"
  description = "HTTPS from VPC to Interface End-points"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from within VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  # all private subnets (map -> list -> ids)
  subnet_ids         = values(aws_subnet.private)[*].id
  security_group_ids = [aws_security_group.vpce_sg.id]

  private_dns_enabled = true # *.amazonaws resolves → VPCE

  tags = {
    Name = "vpce-${each.key}"
  }
}

#########################################
# Gateway Endpoint for S3   (ECR layers)
#########################################
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"


  route_table_ids = [
    aws_route_table.public.id,
    aws_vpc.main.main_route_table_id
  ]

  tags = { Name = "vpce-s3-gateway" }
}
