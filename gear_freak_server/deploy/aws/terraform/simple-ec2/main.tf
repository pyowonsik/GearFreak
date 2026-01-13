terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group for Serverpod Server
resource "aws_security_group" "serverpod" {
  name        = "${var.project_name}-serverpod-sg"
  description = "Security group for Serverpod server"

  # SSH access (restricted to admin IP)
  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Serverpod API Server
  ingress {
    description = "Serverpod API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Serverpod Insights Server
  ingress {
    description = "Serverpod Insights"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Serverpod Web Server
  ingress {
    description = "Serverpod Web"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-serverpod-sg"
    Project     = var.project_name
    Environment = "production"
  }
}

# EC2 Instance for Serverpod
resource "aws_instance" "serverpod" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.serverpod.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    fcm_project_id         = var.fcm_project_id
    aws_access_key_id      = var.aws_access_key_id
    aws_secret_access_key  = var.aws_secret_access_key
    aws_region             = var.aws_region
    s3_public_bucket_name  = var.s3_public_bucket_name
    s3_private_bucket_name = var.s3_private_bucket_name
    db_password            = var.db_password
    redis_password         = var.redis_password
    docker_image_url       = var.docker_image_url
  })

  tags = {
    Name        = "${var.project_name}-serverpod"
    Project     = var.project_name
    Environment = "production"
  }
}

# Elastic IP for EC2 Instance
resource "aws_eip" "serverpod" {
  domain   = "vpc"
  instance = aws_instance.serverpod.id

  tags = {
    Name        = "${var.project_name}-serverpod-eip"
    Project     = var.project_name
    Environment = "production"
  }
}

# Route53 A Record for API
resource "aws_route53_record" "api" {
  zone_id = var.hosted_zone_id
  name    = "api.${var.domain}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.serverpod.public_ip]
}

# Route53 A Record for Insights
resource "aws_route53_record" "insights" {
  zone_id = var.hosted_zone_id
  name    = "insights.${var.domain}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.serverpod.public_ip]
}

# Route53 A Record for Web/App
resource "aws_route53_record" "app" {
  zone_id = var.hosted_zone_id
  name    = "app.${var.domain}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.serverpod.public_ip]
}
