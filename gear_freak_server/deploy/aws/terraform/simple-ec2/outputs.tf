# ====================
# Instance Information
# ====================

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.serverpod.id
}

output "public_ip" {
  description = "Elastic IP address"
  value       = aws_eip.serverpod.public_ip
}

# ====================
# Endpoint URLs
# ====================

output "api_endpoint" {
  description = "API server endpoint URL"
  value       = "https://api.${var.domain}"
}

output "insights_endpoint" {
  description = "Insights server endpoint URL"
  value       = "https://insights.${var.domain}"
}

output "web_endpoint" {
  description = "Web server endpoint URL"
  value       = "https://app.${var.domain}"
}

# ====================
# SSH Access
# ====================

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name}.pem ec2-user@${aws_eip.serverpod.public_ip}"
}

# ====================
# DNS Records
# ====================

output "dns_records" {
  description = "DNS record names"
  value = {
    api      = aws_route53_record.api.name
    insights = aws_route53_record.insights.name
    app      = aws_route53_record.app.name
  }
}
