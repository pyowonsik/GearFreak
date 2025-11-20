# S3 Presigned URL 업로드 설정 가이드

이 가이드는 AWS S3를 사용한 presigned URL 방식의 파일 업로드를 설정하는 전체 과정을 설명합니다.

## 📋 목차

1. [AWS 계정 설정](#1-aws-계정-설정)
2. [Terraform 인프라 배포](#2-terraform-인프라-배포)
3. [Serverpod S3 서비스 구현](#3-serverpod-s3-서비스-구현)
4. [Flutter 클라이언트 구현](#4-flutter-클라이언트-구현)

---

## 1. AWS 계정 설정

### 1.1 AWS 계정 생성 및 로그인

1. [AWS 콘솔](https://console.aws.amazon.com/)에 로그인
2. 아직 계정이 없다면 새로 생성

### 1.2 IAM 사용자 생성 (Terraform 실행용)

Terraform을 실행하기 위해 IAM 사용자를 생성하고 Access Key를 발급받습니다.

1. **IAM 콘솔 접속**
   - AWS 콘솔 → IAM → Users

2. **새 사용자 생성**
   - "Add users" 클릭
   - 사용자 이름: `terraform-user` (또는 원하는 이름)
   - Access type: `Programmatic access` 선택

3. **권한 부여**
   - "Attach existing policies directly" 선택
   - 다음 정책들을 추가:
     - `AdministratorAccess` (개발 환경용, 프로덕션에서는 최소 권한 원칙 적용)
     - 또는 필요한 최소 권한만 부여:
       - `AmazonS3FullAccess`
       - `AmazonEC2FullAccess`
       - `AmazonVPCFullAccess`
       - `IAMFullAccess`
       - `AmazonRoute53FullAccess`
       - `AmazonCloudFrontFullAccess`
       - `AWSCodeDeployFullAccess`

4. **Access Key 저장**
   - Access Key ID와 Secret Access Key를 **안전하게 저장**
   - Secret Access Key는 다시 볼 수 없으므로 반드시 저장!

### 1.3 AWS CLI 설정 (로컬 개발 환경)

```bash
# AWS CLI 설치 (macOS)
brew install awscli

# AWS CLI 설정
aws configure

# 다음 정보 입력:
# AWS Access Key ID: [1.2에서 받은 Access Key ID]
# AWS Secret Access Key: [1.2에서 받은 Secret Access Key]
# Default region name: us-west-2 (또는 원하는 리전)
# Default output format: json
```

### 1.4 환경 변수 설정 (선택사항)

Terraform이 자동으로 AWS CLI 설정을 사용하지만, 환경 변수로도 설정 가능:

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-west-2"
```

---

## 2. Terraform 인프라 배포

### 2.1 Terraform 설치

```bash
# macOS
brew install terraform

# 설치 확인
terraform version
```

### 2.2 Terraform 변수 설정

`gear_freak_server/deploy/aws/terraform/config.auto.tfvars` 파일을 수정:

```hcl
# 필수 설정
project_name = "gear-freak"
aws_region = "us-west-2"

# 도메인 설정 (Route 53에서 호스팅된 도메인이 있어야 함)
hosted_zone_id = "Z1234567890ABC"  # Route 53 호스팅 존 ID
top_domain = "example.com"  # 실제 도메인
certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/..."  # ACM 인증서 ARN
cloudfront_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."  # CloudFront용 (us-east-1)

# S3 버킷 이름 (고유해야 함)
public_storage_bucket_name = "gear-freak-public-storage-3059875"
private_storage_bucket_name = "gear-freak-private-storage-3059875"
```

### 2.3 Terraform 초기화 및 배포

```bash
cd gear_freak_server/deploy/aws/terraform

# Terraform 초기화
terraform init

# 배포 계획 확인
terraform plan

# 인프라 배포
terraform apply

# 확인 메시지에 "yes" 입력
```

### 2.4 배포 확인

```bash
# S3 버킷 확인
aws s3 ls

# 출력 예시:
# gear-freak-public-storage-3059875
# gear-freak-private-storage-3059875
```

---

## 3. Serverpod S3 서비스 구현

### 3.1 pubspec.yaml에 의존성 추가

`gear_freak_server/pubspec.yaml`에 다음 추가:

```yaml
dependencies:
  # ... 기존 의존성들
  aws_s3: ^0.1.0  # 또는 최신 버전
```

또는 직접 `aws_signature_v4` 사용:

```yaml
dependencies:
  # ... 기존 의존성들
  aws_signature_v4: ^2.0.0
  http: ^1.1.0
```

### 3.2 S3 서비스 생성

`gear_freak_server/lib/src/feature/storage/service/s3_service.dart` 파일 생성 (다음 단계에서 구현)

### 3.3 환경 변수 설정

`gear_freak_server/config/development.yaml`에 추가:

```yaml
# S3 설정
s3:
  region: us-west-2
  publicBucketName: gear-freak-public-storage-3059875
  privateBucketName: gear-freak-private-storage-3059875
  # EC2 인스턴스에서는 IAM 역할을 사용하므로 Access Key 불필요
  # 로컬 개발 환경에서만 필요
  accessKeyId: ""  # 로컬 개발용 (선택사항)
  secretAccessKey: ""  # 로컬 개발용 (선택사항)
```

---

## 4. Flutter 클라이언트 구현

### 4.1 HTTP 패키지 추가

`gear_freak_flutter/pubspec.yaml`:

```yaml
dependencies:
  # ... 기존 의존성들
  http: ^1.1.0
```

### 4.2 파일 업로드 서비스 생성

`gear_freak_flutter/lib/common/service/file_upload_service.dart` 파일 생성 (다음 단계에서 구현)

---

## 🔐 보안 주의사항

1. **Access Key 보안**
   - Access Key는 절대 Git에 커밋하지 마세요
   - `.gitignore`에 `.env`, `*.pem`, `credentials.json` 등 추가
   - 프로덕션에서는 IAM 역할 사용 (EC2 인스턴스)

2. **CORS 설정**
   - 프로덕션에서는 `allowed_origins`를 특정 도메인으로 제한
   - 현재는 개발용으로 `["*"]`로 설정됨

3. **S3 버킷 정책**
   - 버킷은 private으로 유지
   - presigned URL을 통해서만 접근 가능

---

## 📝 다음 단계

1. ✅ Terraform 인프라 배포 완료
2. ⏭️ Serverpod S3 서비스 구현
3. ⏭️ Flutter 클라이언트 업로드 로직 구현
4. ⏭️ create_product_screen.dart에 통합

각 단계는 별도로 진행됩니다.

