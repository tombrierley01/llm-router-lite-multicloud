# Define AZs in a variable for consistency
locals {
  azs = ["a", "b"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "litellm-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# PUBLIC SUBNETS (one per AZ)
resource "aws_subnet" "public" {
  for_each                = { for az in local.azs : az => az }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, index(local.azs, each.key))
  availability_zone       = "eu-west-2${each.key}"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-${each.key}"
  }
}

# PRIVATE SUBNETS (one per AZ)
resource "aws_subnet" "private" {
  for_each          = { for az in local.azs : az => az }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 8 + index(local.azs, each.key))
  availability_zone = "eu-west-2${each.key}"
  tags = {
    Name = "private-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = { for az in local.azs : az => aws_subnet.public[az].id }
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

# Security Groups

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    description      = "All traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow ALB ECS (port 8000)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "From ALB on 8000"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
    cidr_blocks      = []
    ipv6_cidr_blocks = []
  }

  egress {
    description      = "All egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway in the first public subnet
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["a"].id   # use the A-zone public subnet
  tags = { Name = "litellm-nat" }
}

# Route table for *each* private subnet (one route table per AZ)
resource "aws_route_table" "private" {
  # keys = "a", "b" (static), values = subnet objects (unknown until apply)
  for_each = { for az in local.azs : az => aws_subnet.private[az] }

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = { Name = "private-${each.key}" }
}

# 2️⃣  Association for each private subnet
resource "aws_route_table_association" "private_assoc" {
  # same static-key trick
  for_each       = { for az in local.azs : az => aws_subnet.private[az] }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}