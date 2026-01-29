# S3 buckets
resource "aws_s3_bucket" "public_storage" {
  bucket        = var.public_storage_bucket_name
  force_destroy = true

  tags = {
    Name = "${var.project_name} public storage"
  }
}

# ACL 비활성화 (최신 AWS S3는 ACL 대신 버킷 정책 사용)
resource "aws_s3_bucket_ownership_controls" "public_storage" {
  bucket = aws_s3_bucket.public_storage.id
  rule {
    object_ownership = "BucketOwnerEnforced"  # ACL 비활성화
  }
}

# Block Public Access 비활성화 (Public 버킷을 위해 필요)
resource "aws_s3_bucket_public_access_block" "public_storage" {
  bucket = aws_s3_bucket.public_storage.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# CORS 설정 (presigned URL 업로드를 위해 필요)
resource "aws_s3_bucket_cors_configuration" "public_storage" {
  bucket = aws_s3_bucket.public_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = ["*"] # 프로덕션에서는 특정 도메인으로 제한하는 것을 권장
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Public 버킷 정책 (누구나 읽기 가능)
resource "aws_s3_bucket_policy" "public_storage" {
  bucket = aws_s3_bucket.public_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.public_storage.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_storage]
}

# ==================== Dev S3 Buckets ====================

resource "aws_s3_bucket" "public_storage_dev" {
  bucket        = "${var.public_storage_bucket_name}-dev"
  force_destroy = true

  tags = {
    Name        = "${var.project_name} dev public storage"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "public_storage_dev" {
  bucket = aws_s3_bucket.public_storage_dev.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "public_storage_dev" {
  bucket = aws_s3_bucket.public_storage_dev.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_cors_configuration" "public_storage_dev" {
  bucket = aws_s3_bucket.public_storage_dev.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "public_storage_dev" {
  bucket = aws_s3_bucket.public_storage_dev.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.public_storage_dev.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_storage_dev]
}

resource "aws_s3_bucket" "private_storage_dev" {
  bucket        = "${var.private_storage_bucket_name}-dev"
  force_destroy = true

  tags = {
    Name        = "${var.project_name} dev private storage"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "private_storage_dev" {
  bucket = aws_s3_bucket.private_storage_dev.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# ==================== Private Storage ====================

resource "aws_s3_bucket" "private_storage" {
  bucket        = var.private_storage_bucket_name
  force_destroy = true

  tags = {
    Name = "${var.project_name} private storage"
  }
}

# ACL 비활성화 (최신 AWS S3는 ACL 대신 버킷 정책 사용)
resource "aws_s3_bucket_ownership_controls" "private_storage" {
  bucket = aws_s3_bucket.private_storage.id
  rule {
    object_ownership = "BucketOwnerEnforced"  # ACL 비활성화
  }
}

# S3 이미지 CDN용 CloudFront Distribution (현재 미사용)
# 추후 이미지 다운로드 기능이 필요하고 성능 최적화가 필요할 때 활성화
# locals {
#   s3_origin_id = "${var.project_name}-storage"
# }

# resource "aws_cloudfront_distribution" "public_storage" {
#   origin {
#     origin_id   = local.s3_origin_id
#     domain_name = aws_s3_bucket.public_storage.bucket_regional_domain_name
#   }
#   enabled = true

#   aliases = ["${var.subdomain_storage}.${var.top_domain}"]

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }
#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   price_class = "PriceClass_100"

#   viewer_certificate {
#     acm_certificate_arn = aws_acm_certificate_validation.cloudfront.certificate_arn
#     ssl_support_method  = "sni-only"
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
# }

# resource "aws_route53_record" "public_storage" {
#   zone_id = var.hosted_zone_id
#   name    = "${var.subdomain_storage}.${var.top_domain}"
#   type    = "CNAME"
#   ttl     = "300"
#   records = ["${aws_cloudfront_distribution.public_storage.domain_name}"]
# }