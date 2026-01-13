# ====================
# Project Configuration
# ====================

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "gear-freak"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-2"
}

# ====================
# Instance Configuration
# ====================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_ami" {
  description = "AMI ID for Amazon Linux 2023 (ap-northeast-2)"
  type        = string
  # Amazon Linux 2023 AMI ID for ap-northeast-2 (updated 2026-01-12)
  default = "ami-0678ccb690e8a9c67"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

# ====================
# Network Configuration
# ====================

variable "ssh_key_name" {
  description = "AWS EC2 key pair name for SSH access"
  type        = string
}

variable "admin_ip" {
  description = "Admin IP address in CIDR format for SSH access (e.g., 1.2.3.4/32)"
  type        = string
}

# ====================
# Domain Configuration
# ====================

variable "domain" {
  description = "Domain name for the application"
  type        = string
  default     = "gear-freaks.com"
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

# ====================
# Environment Variables (Sensitive)
# ====================

variable "fcm_project_id" {
  description = "Firebase Cloud Messaging project ID"
  type        = string
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS access key ID for S3"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for S3"
  type        = string
  sensitive   = true
}

variable "s3_public_bucket_name" {
  description = "S3 public bucket name"
  type        = string
}

variable "s3_private_bucket_name" {
  description = "S3 private bucket name"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
}

variable "docker_image_url" {
  description = "Docker image URL for Serverpod server"
  type        = string
  default     = "pyowonsik/gear-freak-server:latest"
}
