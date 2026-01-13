# Gear Freak Serverpod AWS EC2 배포 전략

**날짜**: 2026-01-12
**분석 대상**: AWS EC2 t3.micro 단일 인스턴스 배포 전략
**목표**: Terraform을 사용한 간단한 EC2 배포 및 Docker Compose 기반 DB 구성

---

## 1. 프로젝트 개요

### 프로젝트 정보
- **이름**: Gear Freak Server
- **프레임워크**: Serverpod 2.9.2
- **언어**: Dart 3.5+
- **아키텍처**: Monolith (API + Insights + Web 통합)

### 주요 기능
- REST API 서버 (포트 8080)
- Insights 관리 서버 (포트 8081)
- Web 서버 (포트 8082)
- Firebase 인증 (Kakao, Naver, Google, Apple)
- FCM 푸시 알림
- AWS S3 스토리지 연동
- PostgreSQL + Redis 캐싱

---

## 2. 현재 로컬 환경 분석

### 2.1 Docker Compose 구성

**파일 위치**: `docker-compose.yaml`

```yaml
services:
  # Development
  postgres:
    image: pgvector/pgvector:pg16
    ports: '8090:5432'
    environment:
      POSTGRES_USER: postgres
      POSTGRES_DB: gear_freak
      POSTGRES_PASSWORD: 'Ato9x5Fa2G8cmcD_D6QuQ_7OToqwU7Zc'
    volumes:
      - gear_freak_data:/var/lib/postgresql/data

  redis:
    image: redis:6.2.6
    ports: '8091:6379'
    command: redis-server --requirepass "KtY1Brzm-d5l66wYVN3PsowAmKzM2EiR"

  # Test (별도 DB)
  postgres_test:
    image: pgvector/pgvector:pg16
    ports: '9090:5432'
    ...

  redis_test:
    image: redis:6.2.6
    ports: '9091:6379'
    ...
```

**특징**:
- pgvector 확장이 포함된 PostgreSQL 16 사용
- Redis 6.2.6 사용
- Development와 Test 환경 분리
- Named volume으로 데이터 영속성 보장

### 2.2 환경변수 설정 (.envrc)

**파일 위치**: `.envrc` (direnv 사용)

```bash
# FCM 설정
export FCM_PROJECT_ID="gear-freak"
export FCM_SERVICE_ACCOUNT_PATH="./config/fcm-service-account.json"

# AWS S3 설정
export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
export AWS_REGION="ap-northeast-2"
export S3_PUBLIC_BUCKET_NAME="gear-freak-public-storage-3059875"
export S3_PRIVATE_BUCKET_NAME="gear-freak-private-storage-3059875"
```

**특징**:
- direnv를 통한 자동 환경변수 로드
- FCM 서비스 계정 파일 경로 지정
- AWS S3 자격증명 및 버킷 정보

### 2.3 Serverpod 설정 파일

**Development 설정** (`config/development.yaml`):
```yaml
apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080
  publicScheme: http

database:
  host: localhost
  port: 8090  # Docker Compose의 postgres 포트
  name: gear_freak
  user: postgres

redis:
  enabled: true
  host: localhost
  port: 8091  # Docker Compose의 redis 포트
```

**Production 설정** (`config/production.yaml`):
```yaml
apiServer:
  port: 8080
  publicHost: api.examplepod.com  # 변경 필요
  publicPort: 443
  publicScheme: https

database:
  host: database.private-production.examplepod.com  # 변경 필요
  port: 5432
  name: serverpod
  user: postgres
  requireSsl: true

redis:
  enabled: false  # 현재 비활성화
  host: redis.private-production.examplepod.com
  port: 6379
```

**비밀번호 설정** (`config/passwords.yaml`):
```yaml
development:
  database: 'Ato9x5Fa2G8cmcD_D6QuQ_7OToqwU7Zc'
  redis: 'KtY1Brzm-d5l66wYVN3PsowAmKzM2EiR'

production:
  database: 'YOUR_PRODUCTION_DB_PASSWORD'  # 변경 필요
  redis: 'YOUR_PRODUCTION_REDIS_PASSWORD'   # 변경 필요
```

### 2.4 Dockerfile 분석

**파일 위치**: `Dockerfile`

```dockerfile
# Build stage
FROM dart:3.5.0 AS build
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server

# Final stage
FROM alpine:latest
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

COPY --from=build /runtime/ /
COPY --from=build /app/bin/server server
COPY --from=build /app/config/ config/
COPY --from=build /app/web/ web/
COPY --from=build /app/migrations/ migrations/
COPY --from=build /app/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

EXPOSE 8080 8081 8082

ENTRYPOINT ./server --mode=$runmode --server-id=$serverid --logging=$logging --role=$role
```

**특징**:
- Multi-stage build로 이미지 크기 최적화
- Alpine Linux 기반 (경량)
- 3개 포트 노출 (API, Insights, Web)
- Monolith 모드로 실행

---

## 3. 기존 Terraform 인프라 분석

### 3.1 현재 배포된 리소스

**사용 중인 AWS 리소스**:
- ✅ S3 Buckets (public/private storage)
- ✅ CloudFront Distribution (CDN)
- ✅ Route53 Records (DNS)
- ✅ ACM Certificate (SSL/TLS)

**미사용 리소스** (`deploy/aws/terraform/unused/`):
- ❌ EC2 Auto Scaling Group
- ❌ Application Load Balancer (ALB)
- ❌ RDS Database
- ❌ ElastiCache Redis
- ❌ VPC 설정
- ❌ CodeDeploy

**참고**: 현재는 S3 + CloudFront만 사용 중이며, Serverpod 서버는 배포되지 않음

### 3.2 Terraform 파일 구조

```
deploy/aws/terraform/
├── main.tf                  # Provider 설정
├── variables.tf             # 변수 정의
├── config.auto.tfvars       # 변수 값
├── certificates.tf          # ACM 인증서
├── storage.tf               # S3 + CloudFront
├── cloudfront-well-known.tf # Universal Links
├── init-script.sh           # EC2 초기화 스크립트
└── unused/                  # 미사용 파일들
    ├── instances.tf
    ├── balancers.tf
    ├── database.tf
    ├── redis.tf
    └── vpc.tf
```

### 3.3 기존 설정 값 (config.auto.tfvars)

```hcl
project_name = "gear-freak"
aws_region = "ap-northeast-2"

# 도메인 설정
hosted_zone_id = "Z0891796X4J567MSHFSJ"
top_domain = "gear-freaks.com"
subdomain_api = "api"
subdomain_insights = "insights"
subdomain_web = "app"

# 인스턴스 설정 (현재 미사용)
instance_type = "t2.micro"
instance_ami = "ami-0ca285d4c2cda3300"  # Amazon Linux 2 (ap-northeast-2)
autoscaling_min_size = 1
autoscaling_max_size = 1
autoscaling_desired_capacity = 1

# 스토리지
public_storage_bucket_name = "gear-freak-public-storage-3059875"
private_storage_bucket_name = "gear-freak-private-storage-3059875"
deployment_bucket_name = "gear-freak-deployment-3059875"

# 데이터베이스 비밀번호 (현재 미사용)
DATABASE_PASSWORD_PRODUCTION = "STRONG_PASSWORD_HERE"
```

---

## 4. EC2 단일 인스턴스 배포 전략

### 4.1 아키텍처 설계

#### 목표
- **단순성**: 최소한의 AWS 리소스 사용
- **비용 효율성**: t3.micro 단일 인스턴스 (AWS Free Tier)
- **유지보수성**: Docker Compose로 DB 관리
- **확장성**: 추후 Auto Scaling, RDS 전환 가능

#### 인프라 구성
```
┌─────────────────────────────────────────┐
│           Route53 (DNS)                 │
│   api.gear-freaks.com                   │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│      CloudFront (Optional)              │
│        SSL Termination                  │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│      EC2 Instance (t3.micro)            │
│  ┌──────────────────────────────────┐   │
│  │  Docker Compose                  │   │
│  │  ├── Serverpod Server (8080-82)  │   │
│  │  ├── PostgreSQL (5432)           │   │
│  │  └── Redis (6379)                │   │
│  └──────────────────────────────────┘   │
│                                          │
│  EBS Volume (gp3, 20GB)                 │
└──────────────────────────────────────────┘
```

### 4.2 필요한 AWS 리소스

#### 필수 리소스
1. **EC2 Instance**
   - Instance Type: `t3.micro` (2 vCPU, 1GB RAM)
   - AMI: Amazon Linux 2023 또는 Ubuntu 22.04
   - Storage: gp3 20GB (프리티어: 30GB)
   - Security Group: 포트 22, 80, 443, 8080-8082 오픈

2. **Elastic IP**
   - 고정 IP 주소 할당
   - Route53 A 레코드 연결

3. **Security Group**
   - SSH (22): 관리자 IP만
   - HTTP (80): 0.0.0.0/0
   - HTTPS (443): 0.0.0.0/0
   - Serverpod Ports (8080-8082): 0.0.0.0/0 또는 CloudFront IP 대역

4. **Route53 Records**
   - A Record: api.gear-freaks.com → Elastic IP
   - A Record: insights.gear-freaks.com → Elastic IP
   - A Record: app.gear-freaks.com → Elastic IP

#### 선택적 리소스
5. **CloudFront Distribution** (선택)
   - HTTPS 지원
   - 캐싱 및 DDoS 보호
   - Origin: EC2 Elastic IP

6. **ACM Certificate**
   - *.gear-freaks.com 와일드카드 인증서
   - CloudFront 또는 ALB 사용 시 필요

### 4.3 인스턴스 스펙 선택

#### t3.micro vs t2.micro
```
┌────────────────┬──────────┬──────────┐
│                │ t3.micro │ t2.micro │
├────────────────┼──────────┼──────────┤
│ vCPU           │ 2        │ 1        │
│ Memory         │ 1 GB     │ 1 GB     │
│ Network        │ Up to 5G │ Low-Mod  │
│ Burst Credits  │ Baseline │ Credit   │
│ 가격 (시간당)  │ ~$0.0104 │ ~$0.0116 │
└────────────────┴──────────┴──────────┘
```

**권장**: t3.micro
- 더 나은 성능
- 낮은 비용
- Baseline CPU 성능 보장

#### 예상 부하
```
Serverpod Server: ~300-500MB RAM
PostgreSQL: ~100-200MB RAM
Redis: ~50-100MB RAM
OS: ~200-300MB RAM
─────────────────────────────────
Total: ~650-1100MB (1GB 내)
```

**주의**: 트래픽 증가 시 t3.small (2GB RAM) 이상 필요

---

## 5. Terraform 구성 계획

### 5.1 디렉토리 구조

```
deploy/aws/terraform/simple-ec2/
├── main.tf                 # EC2, Security Group, Elastic IP
├── variables.tf            # 입력 변수
├── outputs.tf              # 출력 값
├── user-data.sh            # EC2 초기화 스크립트
├── config.auto.tfvars      # 변수 값
└── README.md               # 사용 가이드
```

### 5.2 main.tf 설계

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

# Security Group
resource "aws_security_group" "serverpod" {
  name        = "${var.project_name}-serverpod-sg"
  description = "Security group for Serverpod server"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Serverpod ports
  ingress {
    from_port   = 8080
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-serverpod-sg"
  }
}

# EC2 Instance
resource "aws_instance" "serverpod" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.serverpod.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    fcm_project_id         = var.fcm_project_id
    aws_access_key_id      = var.aws_access_key_id
    aws_secret_access_key  = var.aws_secret_access_key
    aws_region             = var.aws_region
    s3_public_bucket_name  = var.s3_public_bucket_name
    s3_private_bucket_name = var.s3_private_bucket_name
    db_password            = var.db_password
    redis_password         = var.redis_password
  })

  tags = {
    Name = "${var.project_name}-serverpod"
  }
}

# Elastic IP
resource "aws_eip" "serverpod" {
  instance = aws_instance.serverpod.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-serverpod-eip"
  }
}

# Route53 Records
resource "aws_route53_record" "api" {
  zone_id = var.hosted_zone_id
  name    = "api.${var.domain}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.serverpod.public_ip]
}

resource "aws_route53_record" "insights" {
  zone_id = var.hosted_zone_id
  name    = "insights.${var.domain}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.serverpod.public_ip]
}

resource "aws_route53_record" "web" {
  zone_id = var.hosted_zone_id
  name    = "app.${var.domain}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.serverpod.public_ip]
}
```

### 5.3 variables.tf

```hcl
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "gear-freak"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_ami" {
  description = "AMI ID for EC2 instance"
  type        = string
  # Amazon Linux 2023 (ap-northeast-2)
  default     = "ami-0c9c942bd7bf113a2"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "ssh_key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "admin_ip" {
  description = "Admin IP for SSH access (CIDR)"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
  default     = "gear-freaks.com"
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

# Environment Variables
variable "fcm_project_id" {
  description = "Firebase project ID"
  type        = string
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS access key ID for S3"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for S3"
  type        = string
  sensitive   = true
}

variable "s3_public_bucket_name" {
  description = "S3 public bucket name"
  type        = string
}

variable "s3_private_bucket_name" {
  description = "S3 private bucket name"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
}
```

### 5.4 user-data.sh (EC2 초기화 스크립트)

```bash
#!/bin/bash
set -e

# 로그 파일 설정
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== EC2 Initialization Started ==="

# 시스템 업데이트
echo "Updating system packages..."
yum update -y

# Docker 설치
echo "Installing Docker..."
yum install -y docker
systemctl start docker
systemctl enable docker

# Docker Compose 설치
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Git 설치
echo "Installing Git..."
yum install -y git

# 서버 디렉토리 생성
mkdir -p /opt/gear_freak

# 환경변수 파일 생성
cat > /opt/gear_freak/.env <<EOF
FCM_PROJECT_ID=${fcm_project_id}
FCM_SERVICE_ACCOUNT_PATH=./config/fcm-service-account.json
AWS_ACCESS_KEY_ID=${aws_access_key_id}
AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
AWS_REGION=${aws_region}
S3_PUBLIC_BUCKET_NAME=${s3_public_bucket_name}
S3_PRIVATE_BUCKET_NAME=${s3_private_bucket_name}
POSTGRES_PASSWORD=${db_password}
REDIS_PASSWORD=${redis_password}
EOF

# Docker Compose 파일 생성
cat > /opt/gear_freak/docker-compose.yml <<'COMPOSE'
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg16
    container_name: gear_freak_postgres
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_DB: gear_freak
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:6.2.6
    container_name: gear_freak_redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  serverpod:
    image: gear_freak_server:latest
    container_name: gear_freak_serverpod
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "8081:8081"
      - "8082:8082"
    environment:
      - FCM_PROJECT_ID=${FCM_PROJECT_ID}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=${AWS_REGION}
      - S3_PUBLIC_BUCKET_NAME=${S3_PUBLIC_BUCKET_NAME}
      - S3_PRIVATE_BUCKET_NAME=${S3_PRIVATE_BUCKET_NAME}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./config:/app/config:ro

volumes:
  postgres_data:
  redis_data:
COMPOSE

# 환경변수 로드를 위한 스크립트
cat > /opt/gear_freak/load-env.sh <<'SCRIPT'
#!/bin/bash
set -a
source /opt/gear_freak/.env
set +a
exec "$@"
SCRIPT
chmod +x /opt/gear_freak/load-env.sh

# Nginx 설치 (리버스 프록시)
echo "Installing Nginx..."
amazon-linux-extras install -y nginx1
systemctl start nginx
systemctl enable nginx

# Nginx 설정 (HTTPS는 Certbot으로 나중에 설정)
cat > /etc/nginx/conf.d/serverpod.conf <<'NGINX'
# API Server
server {
    listen 80;
    server_name api.gear-freaks.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Insights Server
server {
    listen 80;
    server_name insights.gear-freaks.com;

    location / {
        proxy_pass http://localhost:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Web Server
server {
    listen 80;
    server_name app.gear-freaks.com;

    location / {
        proxy_pass http://localhost:8082;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

systemctl reload nginx

# Docker Compose 서비스 시작 (DB만)
cd /opt/gear_freak
/opt/gear_freak/load-env.sh docker-compose up -d postgres redis

echo "=== EC2 Initialization Completed ==="
echo "Next steps:"
echo "1. Upload fcm-service-account.json to /opt/gear_freak/config/"
echo "2. Build and push Docker image to ECR or Docker Hub"
echo "3. Update docker-compose.yml with correct image"
echo "4. Run: docker-compose up -d serverpod"
echo "5. Setup SSL with Certbot"
```

### 5.5 outputs.tf

```hcl
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.serverpod.id
}

output "public_ip" {
  description = "Elastic IP address"
  value       = aws_eip.serverpod.public_ip
}

output "api_endpoint" {
  description = "API server endpoint"
  value       = "http://api.${var.domain}"
}

output "insights_endpoint" {
  description = "Insights server endpoint"
  value       = "http://insights.${var.domain}"
}

output "web_endpoint" {
  description = "Web server endpoint"
  value       = "http://app.${var.domain}"
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name}.pem ec2-user@${aws_eip.serverpod.public_ip}"
}
```

### 5.6 config.auto.tfvars (예시)

```hcl
project_name = "gear-freak"
aws_region = "ap-northeast-2"

instance_type = "t3.micro"
instance_ami = "ami-0c9c942bd7bf113a2"  # Amazon Linux 2023 (ap-northeast-2)
volume_size = 20

ssh_key_name = "gear-freak-server-key"  # 사전 생성 필요
admin_ip = "YOUR_IP_ADDRESS/32"  # 본인 IP로 변경

domain = "gear-freaks.com"
hosted_zone_id = "Z0891796X4J567MSHFSJ"

# Environment Variables (Sensitive - Terraform Cloud 사용 권장)
fcm_project_id = "gear-freak"
aws_access_key_id = "YOUR_AWS_ACCESS_KEY_ID"
aws_secret_access_key = "YOUR_AWS_SECRET_ACCESS_KEY"
s3_public_bucket_name = "gear-freak-public-storage-3059875"
s3_private_bucket_name = "gear-freak-private-storage-3059875"

db_password = "STRONG_DB_PASSWORD"
redis_password = "KtY1Brzm-d5l66wYVN3PsowAmKzM2EiR"
```

---

## 6. 환경변수 관리 전략

### 6.1 로컬 환경 (direnv → EC2)

**현재 방식**: `.envrc` + direnv

**EC2 전환 방안**:

#### Option 1: EC2 환경변수 파일
```bash
# /opt/gear_freak/.env
FCM_PROJECT_ID=gear-freak
FCM_SERVICE_ACCOUNT_PATH=./config/fcm-service-account.json
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=ap-northeast-2
S3_PUBLIC_BUCKET_NAME=gear-freak-public-storage-3059875
S3_PRIVATE_BUCKET_NAME=gear-freak-private-storage-3059875
POSTGRES_PASSWORD=...
REDIS_PASSWORD=...
```

**Docker Compose에서 로드**:
```yaml
services:
  serverpod:
    env_file:
      - .env
```

#### Option 2: AWS Systems Manager Parameter Store
```bash
# 파라미터 저장
aws ssm put-parameter \
  --name "/gear-freak/fcm-project-id" \
  --value "gear-freak" \
  --type String

aws ssm put-parameter \
  --name "/gear-freak/aws-access-key-id" \
  --value "YOUR_AWS_ACCESS_KEY_ID" \
  --type SecureString

# EC2에서 가져오기
FCM_PROJECT_ID=$(aws ssm get-parameter --name "/gear-freak/fcm-project-id" --query "Parameter.Value" --output text)
```

**장점**:
- 중앙화된 관리
- 암호화 지원 (SecureString)
- 버전 관리
- IAM 권한 제어

**단점**:
- 추가 복잡도
- AWS CLI 필요

#### Option 3: Terraform으로 주입 (선택한 방안)

**장점**:
- 코드와 인프라 통합
- Terraform Cloud Sensitive Variables 사용 가능
- 자동화 용이

**단점**:
- Terraform state에 민감 정보 포함 (암호화 필요)

### 6.2 비밀 정보 관리

#### FCM Service Account 파일
```bash
# 배포 후 수동 업로드
scp -i ~/.ssh/gear-freak-server-key.pem \
    config/fcm-service-account.json \
    ec2-user@<ELASTIC_IP>:/opt/gear_freak/config/
```

#### Serverpod production.yaml 업데이트
```yaml
database:
  host: localhost  # Docker Compose의 postgres
  port: 5432
  name: gear_freak
  user: postgres
  requireSsl: false  # 로컬 연결

redis:
  enabled: true
  host: localhost  # Docker Compose의 redis
  port: 6379
```

---

## 7. 배포 워크플로우

### 7.1 사전 준비

#### 1. SSH Key Pair 생성
```bash
# AWS Console에서 생성 또는 로컬 키 업로드
ssh-keygen -t rsa -b 4096 -f ~/.ssh/gear-freak-server-key -C "gear-freak-ec2"

# AWS에 공개키 업로드
aws ec2 import-key-pair \
  --key-name gear-freak-server-key \
  --public-key-material fileb://~/.ssh/gear-freak-server-key.pub \
  --region ap-northeast-2
```

#### 2. Docker 이미지 빌드 및 푸시

**Option A: Docker Hub**
```bash
# 로컬에서 빌드
cd gear_freak_server
docker build -t yourusername/gear-freak-server:latest .

# Docker Hub에 푸시
docker login
docker push yourusername/gear-freak-server:latest
```

**Option B: AWS ECR**
```bash
# ECR 레포지토리 생성
aws ecr create-repository \
  --repository-name gear-freak-server \
  --region ap-northeast-2

# 로그인
aws ecr get-login-password --region ap-northeast-2 | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com

# 이미지 태그 및 푸시
docker tag gear-freak-server:latest \
  <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com/gear-freak-server:latest

docker push <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com/gear-freak-server:latest
```

#### 3. Terraform 초기화
```bash
cd deploy/aws/terraform/simple-ec2

# config.auto.tfvars 수정 (SSH key, IP 등)

# 초기화
terraform init

# 검증
terraform validate

# 계획 확인
terraform plan
```

### 7.2 배포 단계

#### Step 1: Terraform Apply
```bash
cd deploy/aws/terraform/simple-ec2
terraform apply

# 출력 확인
# Outputs:
# api_endpoint = "http://api.gear-freaks.com"
# instance_id = "i-0123456789abcdef0"
# public_ip = "54.180.XXX.XXX"
# ssh_command = "ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@54.180.XXX.XXX"
```

**배포되는 리소스**:
- EC2 Instance (t3.micro)
- Security Group
- Elastic IP
- Route53 A Records (api, insights, app)
- Docker + Docker Compose 설치
- PostgreSQL + Redis 컨테이너 시작

#### Step 2: FCM 설정 파일 업로드
```bash
ELASTIC_IP=$(terraform output -raw public_ip)

scp -i ~/.ssh/gear-freak-server-key.pem \
    ../../config/fcm-service-account.json \
    ec2-user@$ELASTIC_IP:/opt/gear_freak/config/
```

#### Step 3: EC2 접속 및 확인
```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@$ELASTIC_IP

# Docker 상태 확인
docker ps

# 로그 확인
tail -f /var/log/user-data.log

# DB 연결 테스트
docker exec -it gear_freak_postgres psql -U postgres -d gear_freak
```

#### Step 4: Docker Compose 파일 수정
```bash
cd /opt/gear_freak

# docker-compose.yml 수정 (이미지 URL 업데이트)
vi docker-compose.yml

# serverpod 서비스의 image를 실제 이미지로 변경
# image: yourusername/gear-freak-server:latest
# 또는
# image: <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com/gear-freak-server:latest
```

#### Step 5: Serverpod 서버 시작
```bash
cd /opt/gear_freak

# 환경변수와 함께 Docker Compose 실행
./load-env.sh docker-compose up -d serverpod

# 로그 확인
docker-compose logs -f serverpod

# 전체 컨테이너 상태
docker-compose ps
```

#### Step 6: 마이그레이션 실행
```bash
# 서버 컨테이너 접속
docker exec -it gear_freak_serverpod sh

# 마이그레이션 실행
./server --apply-migrations

# 컨테이너 재시작
exit
docker-compose restart serverpod
```

#### Step 7: 동작 확인
```bash
# API 서버 테스트
curl http://api.gear-freaks.com

# Insights 접속
# 브라우저에서 http://insights.gear-freaks.com

# 로그 모니터링
docker-compose logs -f
```

### 7.3 SSL/HTTPS 설정 (Certbot)

#### Certbot 설치 및 인증서 발급
```bash
# EC2 접속
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@$ELASTIC_IP

# Certbot 설치
sudo yum install -y certbot python3-certbot-nginx

# 인증서 발급 (3개 도메인 동시)
sudo certbot --nginx \
  -d api.gear-freaks.com \
  -d insights.gear-freaks.com \
  -d app.gear-freaks.com \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email

# 자동 갱신 설정 확인
sudo certbot renew --dry-run
```

**결과**:
- HTTP → HTTPS 자동 리다이렉트
- SSL 인증서 자동 갱신 (cron job)
- Nginx 설정 자동 업데이트

---

## 8. 운영 및 유지보수

### 8.1 모니터링

#### 서버 상태 확인
```bash
# SSH 접속
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@<ELASTIC_IP>

# Docker Compose 상태
cd /opt/gear_freak
docker-compose ps

# 로그 확인
docker-compose logs -f serverpod
docker-compose logs -f postgres
docker-compose logs -f redis

# 리소스 사용량
docker stats
htop
df -h
```

#### CloudWatch 모니터링
```bash
# AWS Console → CloudWatch → Metrics → EC2

# 주요 지표:
# - CPUUtilization
# - NetworkIn/Out
# - DiskReadBytes/WriteBytes
# - StatusCheckFailed
```

### 8.2 백업 전략

#### PostgreSQL 백업
```bash
# 자동 백업 스크립트 (/opt/gear_freak/backup.sh)
#!/bin/bash
BACKUP_DIR="/opt/gear_freak/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/postgres_$DATE.sql"

mkdir -p $BACKUP_DIR

docker exec gear_freak_postgres pg_dump -U postgres gear_freak > $BACKUP_FILE

# S3에 업로드
aws s3 cp $BACKUP_FILE s3://gear-freak-private-storage-3059875/backups/

# 7일 이상 된 로컬 백업 삭제
find $BACKUP_DIR -name "postgres_*.sql" -mtime +7 -delete
```

**Cron 설정**:
```bash
# 매일 새벽 3시 백업
0 3 * * * /opt/gear_freak/backup.sh >> /var/log/backup.log 2>&1
```

#### EBS 스냅샷
```bash
# AWS CLI로 스냅샷 생성
aws ec2 create-snapshot \
  --volume-id vol-xxxxx \
  --description "gear-freak-server-$(date +%Y%m%d)" \
  --region ap-northeast-2

# 또는 AWS Console에서 자동 스냅샷 정책 설정
# EC2 → Elastic Block Store → Lifecycle Manager
```

### 8.3 업데이트 배포

#### 새 버전 배포
```bash
# 1. 새 이미지 빌드 및 푸시
cd gear_freak_server
docker build -t yourusername/gear-freak-server:v1.1.0 .
docker push yourusername/gear-freak-server:v1.1.0

# 2. EC2 접속
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@<ELASTIC_IP>

# 3. docker-compose.yml 수정
cd /opt/gear_freak
vi docker-compose.yml
# image: yourusername/gear-freak-server:v1.1.0

# 4. 이미지 pull 및 재시작
docker-compose pull serverpod
docker-compose up -d serverpod

# 5. 로그 확인
docker-compose logs -f serverpod
```

#### Zero-downtime 배포 (향후)
- Blue-Green Deployment
- Rolling Update with Auto Scaling Group
- Health check 추가

### 8.4 보안 관리

#### 정기 점검 항목
```bash
# 1. 시스템 업데이트
sudo yum update -y

# 2. Docker 이미지 업데이트
docker-compose pull
docker-compose up -d

# 3. SSL 인증서 갱신 확인
sudo certbot renew

# 4. 보안 그룹 규칙 검토
aws ec2 describe-security-groups \
  --group-ids sg-xxxxx \
  --region ap-northeast-2

# 5. 로그 분석 (비정상 접근 확인)
sudo tail -f /var/log/nginx/access.log | grep "404\|500"
```

#### 비밀번호 로테이션
```bash
# 1. PostgreSQL 비밀번호 변경
docker exec -it gear_freak_postgres psql -U postgres
ALTER USER postgres WITH PASSWORD 'new_password';

# 2. .env 파일 업데이트
vi /opt/gear_freak/.env
# POSTGRES_PASSWORD=new_password

# 3. config/passwords.yaml 업데이트
vi /opt/gear_freak/config/passwords.yaml

# 4. 서비스 재시작
docker-compose restart serverpod
```

### 8.5 트러블슈팅

#### 일반적인 문제

**1. 서버가 시작되지 않음**
```bash
# 로그 확인
docker-compose logs serverpod

# 일반적인 원인:
# - DB 연결 실패 → PostgreSQL 상태 확인
# - 환경변수 누락 → .env 파일 확인
# - 포트 충돌 → netstat -tulpn | grep 8080
```

**2. DB 연결 오류**
```bash
# PostgreSQL 상태 확인
docker exec gear_freak_postgres pg_isready -U postgres

# 네트워크 확인
docker network inspect gear_freak_default

# 연결 테스트
docker exec gear_freak_serverpod nc -zv postgres 5432
```

**3. 메모리 부족**
```bash
# 메모리 사용량 확인
free -h
docker stats

# 해결책:
# - 인스턴스 타입 업그레이드 (t3.small)
# - Swap 메모리 추가
sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

**4. SSL 인증서 문제**
```bash
# 인증서 상태 확인
sudo certbot certificates

# 수동 갱신
sudo certbot renew --force-renewal

# Nginx 재시작
sudo systemctl restart nginx
```

---

## 9. 비용 분석

### 9.1 AWS 리소스 비용 (월별)

```
┌────────────────────────┬──────────┬──────────┐
│ 리소스                 │ 사용량   │ 비용($)  │
├────────────────────────┼──────────┼──────────┤
│ EC2 t3.micro (750h)    │ 24/7     │ ~7.50    │
│ EBS gp3 (20GB)         │ 20GB     │ ~2.00    │
│ Elastic IP (연결됨)    │ 1개      │ 0.00     │
│ Route53 Hosted Zone    │ 1개      │ ~0.50    │
│ Route53 쿼리 (100만)   │ 변동     │ ~0.40    │
│ Data Transfer (1GB)    │ 변동     │ ~0.09    │
├────────────────────────┼──────────┼──────────┤
│ 총합 (예상)            │          │ ~10.50   │
└────────────────────────┴──────────┴──────────┘
```

**참고**:
- AWS Free Tier (12개월): EC2 t2.micro 750시간/월 무료
- Free Tier 사용 시: ~$3/월 (EBS, Route53만)
- S3, CloudFront는 기존 사용 중 (추가 비용 없음)

### 9.2 확장 시 비용 증가

```
┌────────────────────────┬──────────┬──────────┐
│ 시나리오               │ 리소스   │ 추가비용 │
├────────────────────────┼──────────┼──────────┤
│ 인스턴스 업그레이드    │ t3.small │ +$7.50   │
│ RDS PostgreSQL (db.t3) │ micro    │ +$15     │
│ ElastiCache Redis      │ t3.micro │ +$12     │
│ ALB                    │ 1개      │ +$16     │
│ Auto Scaling (2 inst)  │ t3.micro │ +$7.50   │
└────────────────────────┴──────────┴──────────┘
```

---

## 10. 다음 단계 및 개선 사항

### 10.1 즉시 구현 가능

1. **Terraform 파일 작성**
   - `deploy/aws/terraform/simple-ec2/` 디렉토리 생성
   - main.tf, variables.tf, outputs.tf, user-data.sh 작성

2. **SSH Key 생성 및 등록**
   - AWS Console에서 Key Pair 생성
   - 로컬에 저장

3. **config.auto.tfvars 설정**
   - SSH key name 입력
   - Admin IP 입력
   - 환경변수 값 확인

4. **Terraform Apply**
   - EC2 인스턴스 생성
   - DNS 레코드 설정

5. **서버 배포**
   - Docker 이미지 빌드 및 푸시
   - FCM 파일 업로드
   - Docker Compose 실행

### 10.2 향후 개선 사항

#### Phase 1: 안정성 향상
- [ ] CloudWatch 알림 설정 (CPU, Memory, Disk)
- [ ] 자동 백업 스크립트 구현
- [ ] Health check endpoint 추가
- [ ] Log aggregation (CloudWatch Logs)

#### Phase 2: 보안 강화
- [ ] IAM Role 기반 권한 관리
- [ ] Systems Manager Session Manager (SSH 대체)
- [ ] Secrets Manager로 환경변수 관리
- [ ] Security Group 규칙 최소화

#### Phase 3: 확장성
- [ ] Auto Scaling Group 도입
- [ ] Application Load Balancer 추가
- [ ] RDS PostgreSQL 전환
- [ ] ElastiCache Redis 전환
- [ ] Multi-AZ 배포

#### Phase 4: CI/CD
- [ ] GitHub Actions 배포 워크플로우
- [ ] Blue-Green Deployment
- [ ] 자동화된 테스트
- [ ] Rollback 메커니즘

---

## 11. 참고 자료

### 11.1 공식 문서
- [Serverpod Documentation](https://docs.serverpod.dev/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### 11.2 유용한 명령어

```bash
# Terraform
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
terraform output

# Docker
docker ps
docker logs <container>
docker exec -it <container> sh
docker-compose up -d
docker-compose down
docker-compose logs -f

# AWS CLI
aws ec2 describe-instances
aws s3 ls
aws ssm get-parameter --name "/path/to/param"

# 시스템
systemctl status docker
systemctl status nginx
journalctl -u docker -f
htop
df -h
free -h
```

### 11.3 프로젝트 파일 위치

```
gear_freak_server/
├── .envrc                    # 로컬 환경변수
├── docker-compose.yaml       # 로컬 DB 설정
├── Dockerfile                # 서버 이미지
├── config/
│   ├── development.yaml
│   ├── production.yaml       # 수정 필요
│   ├── passwords.yaml        # 수정 필요
│   └── fcm-service-account.json
└── deploy/aws/terraform/
    ├── simple-ec2/           # 새로 생성 (이 문서 기반)
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── user-data.sh
    │   ├── config.auto.tfvars
    │   └── README.md
    └── (기존 파일들)
```

---

## 12. 요약

### 배포 체크리스트

- [ ] SSH Key Pair 생성 및 등록
- [ ] config.auto.tfvars 설정 (IP, Key 등)
- [ ] Docker 이미지 빌드 및 푸시
- [ ] Terraform init & apply
- [ ] FCM 서비스 계정 파일 업로드
- [ ] production.yaml 수정
- [ ] Docker Compose 파일 수정 (이미지 URL)
- [ ] DB 마이그레이션 실행
- [ ] Serverpod 서버 시작
- [ ] Nginx 설정 확인
- [ ] SSL 인증서 발급 (Certbot)
- [ ] DNS 전파 확인
- [ ] 엔드포인트 테스트
- [ ] 모니터링 설정
- [ ] 백업 스크립트 설정

### 핵심 요점

1. **단순한 아키텍처**: EC2 단일 인스턴스 + Docker Compose
2. **비용 효율적**: 월 ~$10 (Free Tier 사용 시 ~$3)
3. **관리 용이**: Docker Compose로 통합 관리
4. **확장 가능**: 추후 Auto Scaling, RDS 전환 가능
5. **환경변수**: Terraform user-data로 주입
6. **SSL/HTTPS**: Certbot으로 자동 설정

### 주의사항

1. **t3.micro 제한**: 1GB RAM으로 동시 사용자 제한적
2. **단일 장애점**: EC2 다운 시 전체 서비스 중단
3. **백업 중요**: 수동 백업 스크립트 필수
4. **보안 설정**: SSH IP 제한, 정기 업데이트 필요
5. **모니터링**: CloudWatch 알림 설정 권장

---

**작성일**: 2026-01-12
**작성자**: Claude Code Research
**버전**: 1.0.0
