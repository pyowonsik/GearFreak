# SSL/TLS Certificates for CloudFront

# Provider for us-east-1 region (required for CloudFront certificates)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Certificate for CloudFront (us-east-1 region - REQUIRED)
resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name       = var.top_domain
  subject_alternative_names = ["*.${var.top_domain}"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-cloudfront-certificate"
  }
}

# Certificate validation for CloudFront certificate
resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.cloudfront.arn

  validation_record_fqdns = [
    for record in aws_route53_record.certificate_validation_cloudfront : record.fqdn
  ]

  timeouts {
    create = "5m"
  }
}

# DNS validation records for CloudFront certificate
# Note: Route53 records must be created in the main region, but certificate is in us-east-1
resource "aws_route53_record" "certificate_validation_cloudfront" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

