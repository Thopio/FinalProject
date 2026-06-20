# Declaración de variables (las que no vienen en el variables.tf original)
variable "ami_id" { type = string }
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_password" { type = string }
variable "s3_bucket_name" { type = string }

# Data source para las zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_azs        = slice(data.aws_availability_zones.available.names, 0, 2)
  selected_subnet_ids = [for s in aws_subnet.public : s.id] # <--- Agregado para outputs.tf
}

# Red: VPC y Subredes
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_subnet" "public" {
  for_each                = toset(local.selected_azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.key == local.selected_azs[0] ? "10.0.1.0/24" : "10.0.2.0/24"
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = { Name = "${var.name_prefix}-public-${each.key}" }
}

# Internet Gateway para que la VPC tenga salida externa
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  for_each       = toset(local.selected_azs)
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.rt.id
}

# Security Groups (Para EC2 y para el ALB)
resource "aws_security_group" "alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "${var.name_prefix}-web-sg"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancias EC2 detrás de las subredes estáticas
resource "aws_instance" "web" {
  for_each               = toset(local.selected_azs)
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[each.key].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = templatefile("${path.module}/user-data.sh", {
    db_name      = var.db_name
    db_user      = var.db_user
    db_password  = var.db_password
    bucket_name  = var.s3_bucket_name
    aws_region   = var.aws_region
    name_prefix  = var.name_prefix
  })

  tags = { Name = "${var.name_prefix}-${each.key}" }
}

# --- APPLICATION LOAD BALANCER (ALB) ---
resource "aws_lb" "web" { # <--- Cambiado el nombre de recurso a "web" para emparejar outputs.tf
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in aws_subnet.public : s.id]
}

resource "aws_lb_target_group" "web" { # <--- Cambiado el nombre de recurso a "web" para emparejar outputs.tf
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    port                = "80"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Adjuntar las instancias EC2 al Target Group del ALB
resource "aws_lb_target_group_attachment" "web_attach" {
  for_each         = toset(local.selected_azs)
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[each.key].id
  port             = 80
}
