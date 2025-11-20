# S3 버킷 배포 가이드 - 실제 진행 과정

이 문서는 실제로 S3 버킷을 Terraform으로 배포한 전체 과정을 단계별로 정리한 것입니다.

## 📋 목차

1. [필수 도구 설치](#1-필수-도구-설치)
2. [AWS IAM 사용자 생성](#2-aws-iam-사용자-생성)
3. [AWS CLI 설정](#3-aws-cli-설정)
4. [Terraform 설정](#4-terraform-설정)
5. [Terraform 배포](#5-terraform-배포)
6. [배포 확인](#6-배포-확인)
7. [문제 해결](#7-문제-해결)

---

## 1. 필수 도구 설치

### 1.1 Terraform 설치

```bash
# macOS (Homebrew 사용)
brew install terraform

# 설치 확인
terraform --version
# 출력: Terraform v1.5.7
```

**참고**: Homebrew에서 설치한 Terraform은 1.5.7 버전입니다. 최신 버전이 필요하면 [공식 사이트](https://www.terraform.io/downloads.html)에서 다운로드하세요.

### 1.2 AWS CLI 설치

```bash
# macOS (Homebrew 사용)
brew install awscli

# 설치 확인
aws --version
# 출력: aws-cli/2.32.0 Python/3.13.9 Darwin/24.3.0 source/arm64
```

---

## 2. AWS IAM 사용자 생성

### 2.1 AWS 콘솔 접속

1. https://console.aws.amazon.com/ 접속
2. IAM 서비스로 이동: **IAM → Users**

### 2.2 새 사용자 생성

1. **"Add users"** 버튼 클릭
2. **사용자 이름 입력**: `serverpod-gear-freak-s3` (또는 원하는 이름)
3. **AWS Management Console 액세스**: 체크하지 않음 (프로그래밍 방식만 사용)

### 2.3 권한 설정

**옵션 1: 기존 사용자 권한 복사 (S3만 필요한 경우)**
- "권한 복사" 라디오 버튼 선택
- 기존 사용자 선택 (예: `netflix-nestjs-test-user` - `AmazonS3FullAccess` 권한 보유)

**옵션 2: 직접 정책 연결 (전체 인프라 배포 시)**
- "직접 정책 연결" 라디오 버튼 선택
- `AdministratorAccess` 정책 선택

### 2.4 Access Key 생성

1. **"다음"** 클릭
2. **사용 사례 선택**: "Command Line Interface(CLI)" 선택
3. **"다음"** 클릭
4. **Access Key 확인 및 저장**:
   - Access Key ID: `AKIAW5BDRCKQH47SRPH6` (예시)
   - Secret Access Key: `c4XZN+5nADQ100cwMQT0XalXz69SNScqC6D/efoe` (예시)
   - ⚠️ **중요**: Secret Access Key는 다시 볼 수 없으므로 반드시 안전하게 저장!

---

## 3. AWS CLI 설정

### 3.1 자격 증명 설정

```bash
# 방법 1: 대화형 설정
aws configure

# 다음 정보 입력:
# AWS Access Key ID: [2.4에서 받은 Access Key ID]
# AWS Secret Access Key: [2.4에서 받은 Secret Access Key]
# Default region name: ap-northeast-2 (서울 리전)
# Default output format: json
```

또는 명령어로 직접 설정:

```bash
aws configure set aws_access_key_id AKIAW5BDRCKQH47SRPH6
aws configure set aws_secret_access_key "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"
aws configure set default.region ap-northeast-2
aws configure set default.output json
```

### 3.2 설정 확인

```bash
# 설정 확인
aws configure list

# 출력 예시:
# NAME       : VALUE                    : TYPE             : LOCATION
# profile    : <not set>                : None             : None
# access_key : ****************RPH6     : shared-credentials-file
# secret_key : ****************efoe     : shared-credentials-file
# region     : ap-northeast-2           : config-file      : ~/.aws/config
```

### 3.3 인증 테스트

```bash
# 현재 사용자 정보 확인
aws sts get-caller-identity

# 출력 예시:
# {
#     "UserId": "AIDAW5BDRCKQOW7YIH2C2",
#     "Account": "474668405408",
#     "Arn": "arn:aws:iam::474668405408:user/serverpod-gear-freak-s3"
# }
```

---

## 4. Terraform 설정

### 4.1 프로젝트 디렉토리 이동

```bash
cd gear_freak_server/deploy/aws/terraform
```

### 4.2 config.auto.tfvars 파일 확인 및 수정

`config.auto.tfvars` 파일을 열어서 다음 값들을 확인/수정:

```hcl
# 프로젝트 이름
project_name = "gear-freak"

# AWS 리전 (서울)
aws_region = "ap-northeast-2"

# S3 버킷 이름 (고유해야 함)
public_storage_bucket_name = "gear-freak-public-storage-3059875"
private_storage_bucket_name = "gear-freak-private-storage-3059875"

# 데이터베이스 비밀번호 (Terraform 변수 검증을 위해 필요)
DATABASE_PASSWORD_PRODUCTION = "PgrlKCor8l5vAb3215xEUl8lIWZrW73e"
DATABASE_PASSWORD_STAGING = "n0eBMAwFDv5MfmKMGcAPFUynobszm23h"
```

**참고**: 
- 버킷 이름은 전 세계적으로 고유해야 합니다
- 데이터베이스 비밀번호는 `gear_freak_server/config/passwords.yaml` 파일에서 확인

### 4.3 storage.tf 파일 확인

`storage.tf` 파일이 다음 설정을 포함하는지 확인:

- S3 버킷 리소스 정의
- 소유권 제어 설정 (`BucketOwnerEnforced` - ACL 비활성화)
- CORS 설정 (public_storage만)

---

## 5. Terraform 배포

### 5.1 Terraform 초기화

```bash
terraform init
```

**출력 예시**:
```
Initializing the backend...
Initializing modules...
Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 2.77.0 for vpc...
Initializing provider plugins...
- Installing hashicorp/aws v4.67.0...
Terraform has been successfully initialized!
```

### 5.2 배포 계획 확인

S3 버킷만 생성하기 위해 특정 리소스만 타겟팅:

```bash
terraform plan \
  -target=aws_s3_bucket.public_storage \
  -target=aws_s3_bucket.private_storage \
  -target=aws_s3_bucket_acl.public_storage \
  -target=aws_s3_bucket_acl.private_storage \
  -target=aws_s3_bucket_ownership_controls.public_storage \
  -target=aws_s3_bucket_ownership_controls.private_storage \
  -target=aws_s3_bucket_cors_configuration.public_storage
```

**출력 확인**:
- `Plan: 7 to add, 0 to change, 0 to destroy.`
- 생성될 리소스 목록 확인

### 5.3 배포 실행

```bash
terraform apply \
  -target=aws_s3_bucket.public_storage \
  -target=aws_s3_bucket.private_storage \
  -target=aws_s3_bucket_acl.public_storage \
  -target=aws_s3_bucket_acl.private_storage \
  -target=aws_s3_bucket_ownership_controls.public_storage \
  -target=aws_s3_bucket_ownership_controls.private_storage \
  -target=aws_s3_bucket_cors_configuration.public_storage \
  -auto-approve
```

**실제 배포 과정**:

1. **버킷 생성**:
   ```
   aws_s3_bucket.public_storage: Creating...
   aws_s3_bucket.private_storage: Creating...
   aws_s3_bucket.public_storage: Creation complete after 1s
   aws_s3_bucket.private_storage: Creation complete after 1s
   ```

2. **ACL 오류 발생** (최신 AWS S3는 ACL 비활성화):
   ```
   Error: AccessControlListNotSupported: The bucket does not allow ACLs
   ```

3. **storage.tf 수정**:
   - `aws_s3_bucket_acl` 리소스 제거
   - `object_ownership`를 `BucketOwnerEnforced`로 변경

4. **재배포**:
   ```bash
   terraform apply \
     -target=aws_s3_bucket_ownership_controls.public_storage \
     -target=aws_s3_bucket_ownership_controls.private_storage \
     -auto-approve
   ```

---

## 6. 배포 확인

### 6.1 AWS CLI로 확인

```bash
# 버킷 목록 확인
aws s3 ls | grep gear-freak

# 출력:
# 2025-11-20 12:22:13 gear-freak-private-storage-3059875
# 2025-11-20 12:22:13 gear-freak-public-storage-3059875
```

### 6.2 AWS 콘솔에서 확인

1. https://console.aws.amazon.com/s3/ 접속
2. "범용 버킷" 섹션에서 다음 버킷 확인:
   - `gear-freak-public-storage-3059875`
   - `gear-freak-private-storage-3059875`

### 6.3 버킷 설정 확인

각 버킷을 클릭하여 다음 설정 확인:

**Public Storage 버킷**:
- 권한 탭 → CORS 설정 확인
- 소유권 탭 → `BucketOwnerEnforced` 확인

**Private Storage 버킷**:
- 소유권 탭 → `BucketOwnerEnforced` 확인

---

## 7. 문제 해결

### 7.1 ACL 오류

**문제**:
```
Error: AccessControlListNotSupported: The bucket does not allow ACLs
```

**원인**: 최신 AWS S3는 기본적으로 ACL을 비활성화합니다.

**해결**:
1. `storage.tf`에서 `aws_s3_bucket_acl` 리소스 제거
2. `object_ownership`를 `BucketOwnerEnforced`로 변경

```hcl
resource "aws_s3_bucket_ownership_controls" "public_storage" {
  bucket = aws_s3_bucket.public_storage.id
  rule {
    object_ownership = "BucketOwnerEnforced"  # ACL 비활성화
  }
}
```

### 7.2 데이터베이스 비밀번호 오류

**문제**:
```
Error: No value for required variable "DATABASE_PASSWORD_PRODUCTION"
```

**해결**:
`config.auto.tfvars`에 다음 추가:
```hcl
DATABASE_PASSWORD_PRODUCTION = "PgrlKCor8l5vAb3215xEUl8lIWZrW73e"
DATABASE_PASSWORD_STAGING = "n0eBMAwFDv5MfmKMGcAPFUynobszm23h"
```

비밀번호는 `gear_freak_server/config/passwords.yaml`에서 확인.

### 7.3 버킷 이름 충돌

**문제**:
```
Error: BucketAlreadyExists
```

**해결**:
`config.auto.tfvars`에서 버킷 이름을 고유한 이름으로 변경.

---

## 📝 배포 완료 체크리스트

- [x] Terraform 설치 완료
- [x] AWS CLI 설치 완료
- [x] IAM 사용자 생성 완료
- [x] Access Key 생성 및 저장 완료
- [x] AWS CLI 설정 완료
- [x] Terraform 초기화 완료
- [x] S3 버킷 2개 생성 완료
- [x] CORS 설정 완료 (public_storage)
- [x] 소유권 제어 설정 완료
- [x] 배포 확인 완료

---

## 🎯 생성된 리소스

### S3 버킷
- **Public Storage**: `gear-freak-public-storage-3059875`
  - 리전: `ap-northeast-2` (서울)
  - CORS 설정: ✅
  - 소유권: `BucketOwnerEnforced`

- **Private Storage**: `gear-freak-private-storage-3059875`
  - 리전: `ap-northeast-2` (서울)
  - 소유권: `BucketOwnerEnforced`

---

## 🔐 보안 주의사항

1. **Access Key 보안**:
   - Access Key는 절대 Git에 커밋하지 마세요
   - `.gitignore`에 `.aws/` 디렉토리 추가
   - 노출된 Access Key는 즉시 비활성화하고 새로 생성

2. **버킷 보안**:
   - 버킷은 기본적으로 private입니다
   - Presigned URL을 통해서만 접근 가능
   - CORS 설정은 개발 환경용 (`allowed_origins: ["*"]`), 프로덕션에서는 특정 도메인으로 제한

---

## 📚 다음 단계

인프라 설정이 완료되었으므로, 다음은 코드 구현입니다:

1. Serverpod S3 서비스 구현 (presigned URL 생성)
2. Flutter 클라이언트 업로드 로직 구현
3. create_product_screen.dart에 통합

---

## 📅 배포 일시

- **배포 날짜**: 2025년 11월 20일
- **배포 시간**: 오후 12:21:47 PM KST
- **리전**: ap-northeast-2 (서울)

---

## 🔗 참고 자료

- [Terraform AWS Provider 문서](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 문서](https://docs.aws.amazon.com/s3/)
- [AWS IAM 문서](https://docs.aws.amazon.com/iam/)

