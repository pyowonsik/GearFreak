# CloudFront Distribution for serving .well-known files (Universal Links / App Links)
# This distribution serves authentication files from S3 for gear-freaks.com domain

locals {
  well_known_origin_id = "${var.project_name}-well-known"
}

# CloudFront Distribution for .well-known files
resource "aws_cloudfront_distribution" "well_known" {
  origin {
    origin_id   = local.well_known_origin_id
    domain_name = aws_s3_bucket.public_storage.bucket_regional_domain_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled = true

  # Serve from top domain (gear-freaks.com)
  aliases = [var.top_domain]

  # Cache behavior for /product/* paths (fallback page)
  ordered_cache_behavior {
    path_pattern     = "/product/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.well_known_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 300
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Default cache behavior for .well-known files
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.well_known_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0  # No caching for .well-known files
    max_ttl                = 0
    compress               = true
  }

  # Custom error response for 404 -> 200
  # Note: This applies to all 404 errors
  # For .well-known files: will return /.well-known/apple-app-site-association (if exists)
  # For /product/* paths: will return /product/index.html (fallback page)
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/product/index.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/product/index.html"
    error_caching_min_ttl = 300
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cloudfront.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${var.project_name}-well-known"
  }
}

# Route53 DNS record for top domain -> CloudFront
# Route53 DNS record for top domain -> CloudFront (for .well-known files)
# Note: This will conflict with aws_route53_record.web_top_domain if use_top_domain_for_web is true
# In that case, use the same CloudFront distribution or create separate path-based routing
resource "aws_route53_record" "well_known" {
  count   = var.use_top_domain_for_web ? 0 : 1  # Only create if top domain is not used for web
  zone_id = var.hosted_zone_id
  name    = var.top_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.well_known.domain_name
    zone_id                = aws_cloudfront_distribution.well_known.hosted_zone_id
    evaluate_target_health = false
  }
}

