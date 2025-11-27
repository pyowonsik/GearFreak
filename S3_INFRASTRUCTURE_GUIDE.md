# S3 인프라 설정 가이드

이 가이드는 Terraform을 사용하여 S3 버킷과 필요한 IAM 권한을 설정하는 방법을 설명합니다.

## 📋 목차

1. [사전 준비사항](#1-사전-준비사항)
2. [Terraform 설정](#2-terraform-설정)
3. [Terraform 배포](#3-terraform-배포)
4. [배포 확인](#4-배포-확인)
5. [문제 해결](#5-문제-해결)

---

## 1. 사전 준비사항

### 1.1 AWS CLI 설치 및 설정

```bash
# macOS
brew install awscli

# AWS CLI 설정
aws configure

# 다음 정보 입력:
# AWS Access Key ID: [IAM 사용자의 Access Key ID]
# AWS Secret Access Key: [IAM 사용자의 Secret Access Key]
# Default region name: ap-northeast-2 (서울 리전)
# Default output format: json
```

### 1.2 IAM 사용자 생성 (Terraform 실행용)

1. **AWS 콘솔 접속**

   - https://console.aws.amazon.com/ → IAM → Users

2. **새 사용자 생성**

   - "Add users" 클릭
   - 사용자 이름: `serverpod-gear-freak-s3` (또는 원하는 이름)
   - Access type: `Programmatic access` 선택

3. **권한 부여**

   - "Attach existing policies directly" 선택
   - 다음 정책 추가:
     - `AdministratorAccess` (개발 환경용)
     - 또는 필요한 최소 권한:
       - `AmazonS3FullAccess`
       - `AmazonEC2ReadOnlyAccess`
       - `AWSCertificateManagerFullAccess`
       - `AmazonRoute53FullAccess`
       - `CloudFrontFullAccess`

4. **Access Key 저장**
   - Access Key ID와 Secret Access Key를 **안전하게 저장**
   - Secret Access Key는 다시 볼 수 없음!

### 1.3 인증 테스트

```bash
# 현재 사용자 정보 확인
aws sts get-caller-identity
```

---

## 2. Terraform 설정

### 2.1 Terraform 설치

```bash
# macOS
brew install terraform

# 설치 확인
terraform version
```

### 2.2 Terraform 변수 설정

`gear_freak_server/deploy/aws/terraform/config.auto.tfvars` 파일 확인:

```hcl
project_name = "gear-freak"
aws_region = "ap-northeast-2"  # 서울 리전

# S3 버킷 이름 (고유해야 함)
public_storage_bucket_name = "gear-freak-public-storage-3059875"
private_storage_bucket_name = "gear-freak-private-storage-3059875"

# 도메인 설정
hosted_zone_id = "Z0891796X4J567MSHFSJ"
top_domain = "gear-freaks.com"

# 데이터베이스 비밀번호 (Terraform 변수 검증을 위해 필요)
DATABASE_PASSWORD_PRODUCTION = "PgrlKCor8l5vAb3215xEUl8lIWZrW73e"
DATABASE_PASSWORD_STAGING = "n0eBMAwFDv5MfmKMGcAPFUynobszm23h"
```

**중요**: 버킷 이름은 전 세계적으로 고유해야 합니다.

### 2.3 Terraform 초기화

```bash
cd gear_freak_server/deploy/aws/terraform
terraform init
```

---

## 3. Terraform 배포

### 3.1 배포 계획 확인

```bash
terraform plan
```

### 3.2 S3 버킷만 먼저 생성 (선택사항)

```bash
terraform apply \
  -target=aws_s3_bucket.public_storage \
  -target=aws_s3_bucket.private_storage \
  -target=aws_s3_bucket_ownership_controls.public_storage \
  -target=aws_s3_bucket_ownership_controls.private_storage \
  -target=aws_s3_bucket_public_access_block.public_storage \
  -target=aws_s3_bucket_cors_configuration.public_storage \
  -target=aws_s3_bucket_policy.public_storage \
  -auto-approve
```

### 3.3 전체 인프라 배포

```bash
terraform apply
```

---

## 4. 배포 확인

### 4.1 AWS CLI로 확인

```bash
# 버킷 목록 확인
aws s3 ls | grep gear-freak

# 버킷 상세 정보 확인
aws s3api get-bucket-cors --bucket gear-freak-public-storage-3059875
```

### 4.2 AWS 콘솔에서 확인

1. https://console.aws.amazon.com/s3/ 접속
2. 다음 버킷 확인:

   - `gear-freak-public-storage-3059875`
   - `gear-freak-private-storage-3059875`

3. **버킷 설정 확인**:
   - Public Storage: CORS 설정, Public Access Block 비활성화, 버킷 정책
   - Private Storage: 소유권 제어

---

## 5. 문제 해결

### 5.1 버킷 이름 충돌 오류

```
Error: error creating S3 bucket: BucketAlreadyExists
```

**해결**: `config.auto.tfvars`에서 버킷 이름을 변경 (고유한 이름으로)

### 5.2 권한 오류

```
Error: AccessDenied
```

**해결**: IAM 사용자에 필요한 권한이 있는지 확인

### 5.3 리전 오류

```
Error: InvalidParameterValue
```

**해결**: `aws_region`이 올바른지 확인 (예: `ap-northeast-2`)

---

## 📝 참고사항

- **버킷 이름**: 전 세계적으로 고유해야 하며, 소문자와 하이픈(-)만 사용 가능
- **리전**: `ap-northeast-2` (서울) 권장
- **비용**: S3 버킷 자체는 무료, 저장된 데이터와 요청에 따라 과금
- **보안**: Public 버킷은 버킷 정책으로 접근 제어, Private 버킷은 Presigned URL 사용

---

## 🔐 보안 주의사항

1. **Access Key 보안**:

   - Access Key는 절대 Git에 커밋하지 마세요
   - `.gitignore`에 `.aws/` 디렉토리 추가
   - 노출된 Access Key는 즉시 비활성화하고 새로 생성

2. **버킷 보안**:
   - Public 버킷: 버킷 정책으로 읽기 권한 제어
   - Private 버킷: Presigned URL을 통해서만 접근 가능
   - CORS 설정은 개발 환경용 (`allowed_origins: ["*"]`), 프로덕션에서는 특정 도메인으로 제한

---

## 🎯 생성된 리소스

### S3 버킷

- **Public Storage**: `gear-freak-public-storage-3059875`

  - 리전: `ap-northeast-2` (서울)
  - CORS 설정: ✅
  - Public Access Block: 비활성화
  - 버킷 정책: Public 읽기 허용

- **Private Storage**: `gear-freak-private-storage-3059875`
  - 리전: `ap-northeast-2` (서울)
  - 소유권: `BucketOwnerEnforced`

---

## 📚 다음 단계

인프라 설정이 완료되었으므로, 다음은 코드 구현입니다:

1. Serverpod S3 서비스 구현 (presigned URL 생성)
2. Flutter 클라이언트 업로드 로직 구현
3. 상품 생성 화면에 통합
