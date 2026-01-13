# Gear Freak AWS EC2 Deployment

Terraform을 사용한 AWS EC2 단일 인스턴스 배포 설정

---

## 프로젝트 개요

이 디렉토리는 Gear Freak Serverpod 백엔드를 AWS EC2 t3.micro 인스턴스에 배포하기 위한 Terraform 설정을 포함합니다.

**아키텍처**:
```
Route53 DNS
  ↓
Elastic IP (3.36.158.97)
  ↓
EC2 Instance (t3.micro)
  ├── Nginx (리버스 프록시, SSL)
  └── Docker Compose
      ├── Serverpod Server (8080-8082)
      ├── PostgreSQL 16 + pgvector
      └── Redis 6.2.6
```

**엔드포인트**:
- `https://api.gear-freaks.com` - API Server
- `https://insights.gear-freaks.com` - Insights Dashboard
- `https://app.gear-freaks.com` - Web Server

---

## 사전 요구사항

### 필수 도구

- **Terraform**: >= 1.5.0
  ```bash
  # macOS
  brew install terraform

  # 버전 확인
  terraform --version
  ```

- **AWS CLI**: 최신 버전
  ```bash
  # macOS
  brew install awscli

  # 설정
  aws configure
  # AWS Access Key ID: [입력]
  # AWS Secret Access Key: [입력]
  # Default region name: ap-northeast-2
  # Default output format: json
  ```

- **Docker**: 로컬 이미지 빌드용
  ```bash
  # macOS
  brew install docker
  ```

### AWS 리소스

1. **AWS 계정** 및 IAM 사용자 (EC2, Route53, VPC 권한)

2. **SSH Key Pair**
   ```bash
   # AWS Console에서 생성
   # EC2 → Key Pairs → Create key pair
   # Name: gear-freak-server-key
   # Type: RSA
   # Format: .pem

   # 다운로드 후 권한 설정
   chmod 400 ~/.ssh/gear-freak-server-key.pem
   ```

3. **Route53 Hosted Zone**
   ```bash
   # Route53에서 도메인 등록 또는 기존 Hosted Zone ID 확인
   # Example: Z0891796X4J567MSHFSJ
   ```

4. **Docker Hub 계정** (또는 AWS ECR)
   ```bash
   docker login
   # Username: pyowonsik
   # Password: [Docker Hub Access Token]
   ```

---

## 배포 단계

### Step 1: SSH Key 확인

```bash
# AWS에 Key Pair 존재 확인
aws ec2 describe-key-pairs --key-name gear-freak-server-key --region ap-northeast-2

# 로컬 파일 존재 확인
ls -l ~/.ssh/gear-freak-server-key.pem
```

### Step 2: Docker 이미지 빌드 및 푸시

```bash
cd ../../../..  # gear_freak_server 루트로 이동

# 이미지 빌드
docker build -t pyowonsik/gear-freak-server:latest .

# Docker Hub에 푸시
docker push pyowonsik/gear-freak-server:latest

# 푸시 확인
docker pull pyowonsik/gear-freak-server:latest
```

### Step 3: Terraform 변수 설정

```bash
cd deploy/aws/terraform/simple-ec2

# 예제 파일 복사
cp terraform.tfvars.example terraform.tfvars

# terraform.tfvars 편집
vi terraform.tfvars
```

**필수 설정**:
```hcl
# 네트워크 설정
ssh_key_name = "gear-freak-server-key"
admin_ip     = "YOUR_IP/32"  # curl ifconfig.me 로 확인

# 도메인 설정
domain         = "gear-freaks.com"
hosted_zone_id = "Z0891796X4J567MSHFSJ"

# 민감 정보
fcm_project_id         = "gear-freak"
aws_access_key_id      = "YOUR_AWS_ACCESS_KEY_ID"
aws_secret_access_key  = "YOUR_AWS_SECRET_ACCESS_KEY"
s3_public_bucket_name  = "gear-freak-public-storage-3059875"
s3_private_bucket_name = "gear-freak-private-storage-3059875"
db_password            = "STRONG_PASSWORD"
redis_password         = "STRONG_PASSWORD"
docker_image_url       = "pyowonsik/gear-freak-server:latest"
```

### Step 4: Terraform 초기화 및 배포

```bash
# Terraform 초기화
terraform init

# 문법 검증
terraform validate

# 실행 계획 확인
terraform plan

# 배포 (승인 필요)
terraform apply

# 출력 값 확인
terraform output
```

**예상 출력**:
```
instance_id       = "i-0335f0e8b99af2f6c"
public_ip         = "3.36.158.97"
api_endpoint      = "https://api.gear-freaks.com"
insights_endpoint = "https://insights.gear-freaks.com"
web_endpoint      = "https://app.gear-freaks.com"
ssh_command       = "ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97"
```

### Step 5: EC2 초기화 확인

```bash
# SSH 접속
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

# User Data 로그 확인
tail -f /var/log/user-data.log

# 초기화 완료 확인 (.initialized 파일 생성됨)
ls -l /opt/gear_freak/.initialized

# Docker 및 컨테이너 상태 확인
docker --version
docker-compose --version
docker ps

# PostgreSQL, Redis 실행 확인
cd /opt/gear_freak
docker-compose ps
```

### Step 6: FCM 서비스 계정 파일 업로드

```bash
# 로컬에서 실행 (gear_freak_server 루트)
scp -i ~/.ssh/gear-freak-server-key.pem \
    config/fcm-service-account.json \
    ec2-user@3.36.158.97:/opt/gear_freak/config/

# 권한 설정
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
chmod 600 /opt/gear_freak/config/fcm-service-account.json
```

### Step 7: production.yaml 및 passwords.yaml 확인

```bash
# EC2에서 실행
cd /opt/gear_freak/config

# production.yaml 확인 (이미 git으로 배포됨)
cat production.yaml

# passwords.yaml 생성 (없는 경우)
cat > passwords.yaml <<EOF
production:
  database: 'YOUR_DB_PASSWORD'  # .env의 POSTGRES_PASSWORD와 동일
  redis: 'YOUR_REDIS_PASSWORD'     # .env의 REDIS_PASSWORD와 동일
EOF

chmod 600 passwords.yaml
```

### Step 8: Serverpod 서버 시작

```bash
# EC2에서 실행
cd /opt/gear_freak

# Serverpod 컨테이너 시작
docker-compose up -d serverpod

# 로그 확인 (서버 시작 확인)
docker-compose logs -f serverpod

# 예상 로그:
# SERVERPOD initialized
# Insights listening on port 8081
# Server default listening on port 8080
# Webserver listening on port 8082
```

### Step 9: DB 마이그레이션 실행

```bash
# 로컬에서 최신 마이그레이션 파일 복사
MIGRATION_DIR=$(ls -1d migrations/*/ | sort -r | head -1)
scp -i ~/.ssh/gear-freak-server-key.pem \
    ${MIGRATION_DIR}definition.sql \
    ec2-user@3.36.158.97:/tmp/migration.sql

# EC2에서 마이그레이션 실행
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
docker exec -i gear_freak_postgres psql -U postgres -d gear_freak < /tmp/migration.sql

# Serverpod 재시작
cd /opt/gear_freak
docker-compose restart serverpod
```

### Step 10: DNS 전파 확인

```bash
# 로컬에서 DNS 확인
dig api.gear-freaks.com +short
dig insights.gear-freaks.com +short
dig app.gear-freaks.com +short

# Elastic IP와 일치 확인
# 3.36.158.97

# DNS 전파 대기 (최대 5분)
```

### Step 11: SSL 인증서 발급 (Certbot)

```bash
# EC2에서 실행

# Certbot 설치 확인
which certbot

# SSL 인증서 발급
sudo certbot --nginx \
  -d api.gear-freaks.com \
  -d insights.gear-freaks.com \
  -d app.gear-freaks.com \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email \
  --redirect

# 성공 메시지 확인:
# Successfully received certificate.
# Certificate is saved at: /etc/letsencrypt/live/api.gear-freaks.com/fullchain.pem

# Nginx 재시작
sudo systemctl reload nginx
```

### Step 12: 최종 확인

```bash
# HTTPS 접속 테스트
curl https://api.gear-freaks.com
curl https://insights.gear-freaks.com
curl https://app.gear-freaks.com

# 브라우저 테스트
open https://insights.gear-freaks.com

# SSL 인증서 확인
echo | openssl s_client -servername api.gear-freaks.com -connect api.gear-freaks.com:443 2>/dev/null | openssl x509 -noout -dates
```

---

## 운영 가이드

### 서버 접속 방법

```bash
# SSH 접속
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

# 작업 디렉토리
cd /opt/gear_freak
```

### 로그 확인 방법

```bash
# Serverpod 로그
docker-compose logs -f serverpod

# PostgreSQL 로그
docker-compose logs -f postgres

# Redis 로그
docker-compose logs -f redis

# Nginx 로그
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# 특정 도메인 로그
sudo tail -f /var/log/nginx/api.gear-freaks.com.access.log
```

### 백업 확인 방법

```bash
# 로컬 백업 파일 확인
ls -lh /opt/gear_freak/backups/

# S3 백업 확인
aws s3 ls s3://gear-freak-private-storage-3059875/backups/

# 수동 백업 실행
/opt/gear_freak/backup.sh
```

### 업데이트 배포 방법

**코드 변경 시**:
```bash
# 로컬에서 Docker 이미지 빌드 & 푸시
docker build -t pyowonsik/gear-freak-server:latest .
docker push pyowonsik/gear-freak-server:latest

# EC2에서 업데이트
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
cd /opt/gear_freak
docker-compose pull serverpod
docker-compose up -d serverpod
```

**DB 스키마 변경 시**:
```bash
# 로컬에서 마이그레이션 파일 복사
scp -i ~/.ssh/gear-freak-server-key.pem \
    migrations/[최신]/migration.sql \
    ec2-user@3.36.158.97:/tmp/

# EC2에서 마이그레이션 실행
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
docker exec -i gear_freak_postgres psql -U postgres -d gear_freak < /tmp/migration.sql
cd /opt/gear_freak
docker-compose restart serverpod
```

자세한 배포 방법은 [DEPLOYMENT.md](DEPLOYMENT.md) 참조

---

## 트러블슈팅

### 문제 1: SSH 접속 실패

**증상**: `Permission denied (publickey)`

**해결**:
```bash
# SSH 키 권한 확인
chmod 400 ~/.ssh/gear-freak-server-key.pem

# Security Group 확인
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw security_group_id) \
  --region ap-northeast-2

# admin_ip 확인 (현재 IP와 일치해야 함)
curl ifconfig.me
```

### 문제 2: Terraform apply 실패

**증상**: `Error creating EC2 instance`

**해결**:
```bash
# AWS 자격증명 확인
aws sts get-caller-identity

# Terraform 상태 확인
terraform state list

# 특정 리소스 재생성
terraform taint aws_instance.serverpod
terraform apply
```

### 문제 3: Serverpod 컨테이너 시작 실패

**증상**: `Container exited with code 1`

**해결**:
```bash
# 로그 확인
docker logs gear_freak_serverpod --tail 100

# 일반적인 원인:
# 1. DB 연결 실패 → production.yaml의 host 확인 (postgres)
# 2. 환경변수 누락 → docker exec gear_freak_serverpod env 확인
# 3. FCM 파일 없음 → ls /opt/gear_freak/config/fcm-service-account.json

# DB 연결 테스트
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c "SELECT version();"
```

### 문제 4: HTTPS 접속 불가

**증상**: `SSL_ERROR_BAD_CERT_DOMAIN`

**해결**:
```bash
# DNS 전파 확인
dig api.gear-freaks.com +short

# Certbot 인증서 상태 확인
sudo certbot certificates

# 인증서 재발급
sudo certbot renew --force-renewal
sudo systemctl reload nginx
```

### 문제 5: DB 마이그레이션 오류

**증상**: `ERROR: relation already exists`

**해결**:
```bash
# definition.sql 대신 migration.sql 사용
# migration.sql은 증분 변경만 적용

# 또는 특정 테이블만 DROP 후 재생성
docker exec -it gear_freak_postgres psql -U postgres -d gear_freak
DROP TABLE IF EXISTS [table_name] CASCADE;
\q

# 다시 마이그레이션 실행
docker exec -i gear_freak_postgres psql -U postgres -d gear_freak < /tmp/migration.sql
```

---

## 비용 정보

### 월간 예상 비용 (ap-northeast-2)

| 리소스 | 사양 | 비용 | Free Tier |
|--------|------|------|-----------|
| EC2 t3.micro | 2 vCPU, 1GB RAM | $7.50 | 750시간/월 무료 |
| EBS gp3 | 20GB | $2.00 | 30GB 무료 |
| Elastic IP | 연결됨 | $0 | 무료 |
| Route53 | Hosted Zone | $0.50 | - |
| Route53 Queries | ~1M queries | $0.40 | 1M queries 무료 |
| Data Transfer | ~10GB/월 | $0.90 | 100GB 무료 |
| **총계** | | **~$11.30/월** | **Free Tier: ~$3/월** |

**비용 절감 팁**:
- Free Tier 활용 (12개월)
- Reserved Instance 구매 (1년 약정 시 ~40% 할인)
- CloudWatch 알람 설정 (월 $20 초과 시 알림)

---

## 참고 자료

### 프로젝트 문서

- **배포 가이드**: [DEPLOYMENT.md](DEPLOYMENT.md)
- **운영 체크리스트**: [OPERATIONS.md](OPERATIONS.md)
- **배포 계획**: [thoughts/shared/plans/aws_ec2_deployment_plan_2026-01-12.md](../../../../thoughts/shared/plans/aws_ec2_deployment_plan_2026-01-12.md)
- **검증 보고서**: [thoughts/shared/validate/aws_ec2_deployment_validation_2026-01-13.md](../../../../thoughts/shared/validate/aws_ec2_deployment_validation_2026-01-13.md)

### Terraform 파일

- **main.tf**: 메인 리소스 정의 (EC2, Security Group, Elastic IP, Route53)
- **variables.tf**: 입력 변수 정의
- **outputs.tf**: 출력 값 정의
- **user-data.sh**: EC2 초기화 스크립트
- **docker-compose.production.yml**: Docker Compose 설정
- **nginx.conf.template**: Nginx 설정 템플릿

### 외부 문서

- [Serverpod Deployment Guide](https://docs.serverpod.dev/deployment)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [Let's Encrypt Certbot](https://certbot.eff.org/)

### 유용한 명령어

```bash
# Terraform 상태 확인
terraform state list
terraform show

# EC2 인스턴스 상태 확인
aws ec2 describe-instance-status --instance-ids $(terraform output -raw instance_id)

# Docker 컨테이너 리소스 사용량
docker stats

# PostgreSQL 테이블 목록
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c '\dt'

# Nginx 설정 테스트
sudo nginx -t

# SSL 인증서 자동 갱신 테스트
sudo certbot renew --dry-run
```

---

## 지원

**이슈 보고**:
- GitHub Issues: [gear_freak 저장소]
- 긴급 문제: [담당자 연락처]

**문서 업데이트**:
- 작성일: 2026-01-13
- 작성자: Claude Code
- 마지막 검증: 2026-01-13 (EC2 배포 완료 후)

---

**다음 단계**: [OPERATIONS.md](OPERATIONS.md)에서 일일/주간 운영 체크리스트 확인
