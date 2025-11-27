# Terraform 파일 상태 정리

## 📋 개요

현재 프로젝트에서 사용 중인 Terraform 파일과 사용하지 않는 파일을 정리한 문서입니다.

---

## ✅ 사용 중인 파일

### 1. `main.tf`

**용도**: Terraform 및 AWS Provider 기본 설정

- Terraform 버전 요구사항
- AWS Provider 설정
- 리전 설정

**상태**: ✅ 사용 중

---

### 2. `certificates.tf`

**용도**: SSL/TLS 인증서 관리 (ACM)

- CloudFront용 인증서 (us-east-1)
- Route53 DNS 검증 레코드

**리소스**:

- `aws_acm_certificate.cloudfront` (CloudFront용)
- `aws_acm_certificate_validation.cloudfront`
- `aws_route53_record.certificate_validation_cloudfront`

**참고**: ALB용 인증서는 제거됨 (현재 ALB 미사용)

**상태**: ✅ 사용 중

---

### 3. `storage.tf`

**용도**: S3 버킷 및 CloudFront Distribution 설정

- Public Storage 버킷 (인증 파일, 정적 파일)
- Private Storage 버킷 (프라이빗 파일)
- CloudFront Distribution for S3
- S3 버킷 정책 및 CORS 설정

**리소스**:

- `aws_s3_bucket.public_storage`
- `aws_s3_bucket.private_storage`
- `aws_s3_bucket_ownership_controls` (public, private)
- `aws_s3_bucket_public_access_block.public_storage`
- `aws_s3_bucket_cors_configuration.public_storage`
- `aws_s3_bucket_policy.public_storage`
- `aws_cloudfront_distribution.public_storage`
- `aws_route53_record.public_storage`

**상태**: ✅ 사용 중

---

### 4. `cloudfront-well-known.tf`

**용도**: Universal Links/App Links용 CloudFront Distribution

- `.well-known` 파일 서빙
- `/product/*` 경로 fallback 페이지 처리
- Route53 DNS 레코드

**리소스**:

- `aws_cloudfront_distribution.well_known`
- `aws_route53_record.well_known`

**상태**: ✅ 사용 중

---

### 5. `variables.tf`

**용도**: Terraform 변수 정의

- 프로젝트 설정 변수
- 인스턴스 설정 변수
- 네트워크 설정 변수
- 도메인 설정 변수

**상태**: ✅ 사용 중

---

### 6. `config.auto.tfvars`

**용도**: 변수 값 설정

- 실제 배포에 사용되는 변수 값들

**상태**: ✅ 사용 중

---

## ❌ 사용하지 않는 파일 (unused/ 폴더로 이동됨)

### 1. `balancers.tf`

**용도**: Application Load Balancer (ALB) 설정

- 프로덕션 환경용 ALB
- 타겟 그룹 설정
- 리스너 설정

**상태**: ❌ 사용하지 않음 (현재 S3 + CloudFront만 사용)
**Terraform State**: 리소스 없음
**위치**: `unused/` 폴더로 이동됨 ✅

**참고**: Terraform은 `unused/` 폴더의 파일을 자동으로 무시합니다.

---

### 2. `balancers-staging.tf`

**용도**: Staging 환경용 ALB 설정

- Staging 환경용 ALB
- 타겟 그룹 설정
- 리스너 설정

**상태**: ❌ 사용하지 않음
**Terraform State**: 리소스 없음
**위치**: `unused/` 폴더로 이동됨 ✅

**참고**: Terraform은 `unused/` 폴더의 파일을 자동으로 무시합니다.

---

### 3. `cloudfront-web.tf`

**용도**: 웹 서버용 CloudFront Distribution

- ALB를 origin으로 하는 CloudFront
- 웹 애플리케이션 서빙용

**상태**: ❌ 사용하지 않음 (현재 Serverpod 서버 미배포)
**Terraform State**: 리소스 없음
**위치**: `unused/` 폴더로 이동됨 ✅

**참고**: Terraform은 `unused/` 폴더의 파일을 자동으로 무시합니다.

---

### 4. `cloudfront-web-staging.tf`

**용도**: Staging 웹 서버용 CloudFront Distribution

- Staging ALB를 origin으로 하는 CloudFront

**상태**: ❌ 사용하지 않음
**Terraform State**: 리소스 없음
**위치**: `unused/` 폴더로 이동됨 ✅

**참고**: Terraform은 `unused/` 폴더의 파일을 자동으로 무시합니다.

---

### 5. `instances.tf`

**용도**: EC2 인스턴스 설정

- Auto Scaling Group
- Launch Template
- EC2 인스턴스 생성

**상태**: ❌ 사용하지 않음 (현재 EC2 인스턴스 미사용)
**Terraform State**: 리소스 없음
**위치**: `unused/` 폴더로 이동됨 ✅

**참고**: Terraform은 `unused/` 폴더의 파일을 자동으로 무시합니다.

---

## 📊 현재 배포된 리소스 요약

### Terraform State에 있는 리소스들

```
✅ aws_acm_certificate.cloudfront
✅ aws_acm_certificate_validation.cloudfront
✅ aws_cloudfront_distribution.well_known
✅ aws_route53_record.certificate_validation_cloudfront
✅ aws_route53_record.well_known
✅ aws_s3_bucket.private_storage
✅ aws_s3_bucket.public_storage
✅ aws_s3_bucket_cors_configuration.public_storage
✅ aws_s3_bucket_ownership_controls (private, public)
✅ aws_s3_bucket_policy.public_storage
✅ aws_s3_bucket_public_access_block.public_storage
```

---

## 🎯 현재 프로젝트 구조

### 사용 중인 인프라

```
Route53 (DNS)
  ↓
CloudFront Distribution (well_known)
  ↓
S3 Bucket (public_storage)
  ├── .well-known/
  │   ├── apple-app-site-association
  │   └── assetlinks.json
  └── product/
      └── index.html
```

### 미사용 인프라 (향후 필요 시)

- EC2 인스턴스
- Application Load Balancer (ALB)
- Auto Scaling Group
- Serverpod 서버 배포

---

## 📝 참고 사항

### 현재 프로젝트는 다음만 사용:

1. **S3**: 정적 파일 저장 (인증 파일, fallback 페이지)
2. **CloudFront**: CDN 및 HTTPS 제공
3. **Route53**: DNS 관리
4. **ACM**: SSL/TLS 인증서

### 향후 필요 시 추가할 수 있는 것들:

- EC2 인스턴스 (Serverpod 서버 배포용)
- ALB (로드 밸런싱)
- Auto Scaling (자동 확장)
- RDS (데이터베이스)
- ElastiCache (Redis)

---

## 🔄 파일 정리 완료

### ✅ 미사용 파일 이동 완료

다음 파일들은 `unused/` 폴더로 이동되었습니다:

```
✅ balancers.tf → unused/
✅ balancers-staging.tf → unused/
✅ cloudfront-web.tf → unused/
✅ cloudfront-web-staging.tf → unused/
✅ instances.tf → unused/
```

**중요**: Terraform은 `unused/` 폴더의 파일을 **자동으로 무시**합니다.

- `terraform plan` 실행 시 `unused/` 폴더의 파일은 읽지 않음 ✅
- `terraform apply` 실행 시 `unused/` 폴더의 파일은 적용되지 않음 ✅
- **과금 걱정 없음** ✅

### 현재 사용 중인 파일만 유지

다음 파일들만 실제로 사용 중입니다:

```
✅ main.tf
✅ certificates.tf
✅ storage.tf
✅ cloudfront-well-known.tf
✅ variables.tf
✅ config.auto.tfvars
```

### unused/ 폴더에 있는 추가 파일들

다음 파일들도 `unused/` 폴더에 보관되어 있습니다 (향후 필요 시 참고용):

```
unused/
├── balancers.tf
├── balancers-staging.tf
├── cloudfront-web.tf
├── cloudfront-web-staging.tf
├── instances.tf
├── vpc.tf
├── database.tf
├── redis.tf
├── code-deploy.tf
└── staging.tf
```

**참고**: 이 파일들은 Terraform이 자동으로 무시하므로 안전하게 보관할 수 있습니다.

---

## 📅 마지막 업데이트

- 날짜: 2025-11-26
- 상태: Universal Links/App Links 구현 완료
- 배포된 리소스: S3, CloudFront, Route53, ACM
