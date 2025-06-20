resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "litellm-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  for_each                = toset(["a", "b"])
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, index(["a", "b"], each.key))
  availability_zone       = "eu-west-2${each.key}"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each          = toset(["a", "b"])
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 8 + index(["a", "b"], each.key))
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
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

/* SGs */
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
  description = "Allow ALB -> ECS (port 4000)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description              = "From ALB on 4000"
    from_port                = 4000
    to_port                  = 4000
    protocol                 = "tcp"
    security_groups          = [aws_security_group.alb_sg.id]  # reference ALB SG
    ipv6_cidr_blocks         = []
    cidr_blocks              = []
    prefix_list_ids          = []
    self                     = false
  }

  egress {
    description      = "All egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
}
