# S3 인프라 설정 가이드

이 가이드는 Terraform을 사용하여 S3 버킷과 필요한 IAM 권한을 설정하는 방법을 설명합니다.

## 📋 사전 준비사항

### 1. AWS 계정 및 IAM 사용자 설정

#### 1.1 AWS CLI 설치 및 설정

```bash
# macOS
brew install awscli

# AWS CLI 설정
aws configure

# 다음 정보 입력:
# AWS Access Key ID: [IAM 사용자의 Access Key ID]
# AWS Secret Access Key: [IAM 사용자의 Secret Access Key]
# Default region name: ap-northeast-2 (서울 리전) 또는 us-west-2
# Default output format: json
```

#### 1.2 IAM 사용자 생성 (Terraform 실행용)

1. **AWS 콘솔 접속**

   - https://console.aws.amazon.com/ → IAM → Users

2. **새 사용자 생성**

   - "Add users" 클릭
   - 사용자 이름: `terraform-user`
   - Access type: `Programmatic access` 선택

3. **권한 부여**

   - "Attach existing policies directly" 선택
   - 다음 정책 추가:
     - `AdministratorAccess` (개발 환경용)
     - 또는 필요한 최소 권한:
       - `AmazonS3FullAccess`
       - `AmazonEC2FullAccess`
       - `AmazonVPCFullAccess`
       - `IAMFullAccess`
       - `AmazonRoute53FullAccess`
       - `AmazonCloudFrontFullAccess`
       - `AWSCodeDeployFullAccess`

4. **Access Key 저장**
   - Access Key ID와 Secret Access Key를 **안전하게 저장**
   - Secret Access Key는 다시 볼 수 없음!

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
aws_region = "ap-northeast-2"  # 서울 리전 (또는 원하는 리전)

# S3 버킷 이름 (고유해야 함, 이미 설정되어 있음)
public_storage_bucket_name = "gear-freak-public-storage-3059875"
private_storage_bucket_name = "gear-freak-private-storage-3059875"
```

**중요**: 버킷 이름은 전 세계적으로 고유해야 합니다. 이미 사용 중인 이름이면 변경하세요.

### 2.3 Terraform 초기화

```bash
cd gear_freak_server/deploy/aws/terraform

# Terraform 초기화
terraform init
```

### 2.4 Terraform 계획 확인

```bash
# 배포 계획 확인 (실제로 생성되기 전에 무엇이 생성될지 확인)
terraform plan
```

출력에서 다음을 확인:

- `aws_s3_bucket.public_storage` 생성 예정
- `aws_s3_bucket.private_storage` 생성 예정
- `aws_s3_bucket_cors_configuration.public_storage` 생성 예정
- IAM 정책 및 역할 생성 예정

### 2.5 S3 버킷만 먼저 생성 (선택사항)

전체 인프라를 배포하지 않고 S3 버킷만 먼저 생성하려면:

```bash
# S3 버킷만 타겟팅하여 생성
terraform apply -target=aws_s3_bucket.public_storage -target=aws_s3_bucket.private_storage -target=aws_s3_bucket_acl.public_storage -target=aws_s3_bucket_acl.private_storage -target=aws_s3_bucket_ownership_controls.public_storage -target=aws_s3_bucket_ownership_controls.private_storage -target=aws_s3_bucket_cors_configuration.public_storage
```

### 2.6 전체 인프라 배포

```bash
# 전체 인프라 배포
terraform apply

# 확인 메시지에 "yes" 입력
```

---

## 3. 배포 확인

### 3.1 AWS 콘솔에서 확인

1. **S3 콘솔 접속**

   - https://console.aws.amazon.com/s3/
   - "범용 버킷" 섹션에서 다음 버킷들이 보여야 함:
     - `gear-freak-public-storage-3059875`
     - `gear-freak-private-storage-3059875`

2. **버킷 설정 확인**
   - 각 버킷 클릭 → "권한" 탭
   - "퍼블릭 액세스 차단 설정" 확인 (모두 차단되어 있어야 함)
   - "CORS" 탭 (public_storage만) → CORS 규칙 확인

### 3.2 AWS CLI로 확인

```bash
# 버킷 목록 확인
aws s3 ls

# 출력 예시:
# gear-freak-public-storage-3059875
# gear-freak-private-storage-3059875

# 버킷 상세 정보 확인
aws s3api get-bucket-cors --bucket gear-freak-public-storage-3059875
```

---

## 4. 문제 해결

### 4.1 버킷 이름 충돌 오류

```
Error: error creating S3 bucket: BucketAlreadyExists
```

**해결**: `config.auto.tfvars`에서 버킷 이름을 변경 (고유한 이름으로)

### 4.2 권한 오류

```
Error: AccessDenied
```

**해결**: IAM 사용자에 필요한 권한이 있는지 확인

### 4.3 리전 오류

```
Error: InvalidParameterValue
```

**해결**: `aws_region`이 올바른지 확인 (예: `ap-northeast-2`, `us-west-2`)

---

## 5. 다음 단계

✅ S3 버킷 생성 완료 후:

1. Serverpod S3 서비스 구현
2. Flutter 클라이언트 업로드 로직 구현
3. create_product_screen.dart에 통합

---

## 📝 참고사항

- **버킷 이름**: 전 세계적으로 고유해야 하며, 소문자와 하이픈(-)만 사용 가능
- **리전**: `ap-northeast-2` (서울) 또는 `us-west-2` (오레곤) 권장
- **비용**: S3 버킷 자체는 무료, 저장된 데이터와 요청에 따라 과금
- **보안**: 버킷은 기본적으로 private이며, presigned URL을 통해서만 접근 가능
