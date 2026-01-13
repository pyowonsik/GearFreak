# AWS EC2 단일 인스턴스 배포 구현 계획

**날짜**: 2026-01-12
**작성자**: Claude Code
**관련 연구 문서**: `thoughts/shared/research/aws_ec2_deployment_strategy_2026-01-12.md`

---

## 1. 요구사항

### 기능 개요

Terraform을 사용하여 AWS EC2 t3.micro 단일 인스턴스에 Gear Freak Serverpod 서버를 배포합니다. Docker Compose를 통해 PostgreSQL과 Redis를 함께 실행하며, Nginx 리버스 프록시와 Certbot SSL을 통해 HTTPS를 지원합니다.

### 목표

- EC2 단일 인스턴스에 Serverpod 서버 배포
- Docker Compose로 PostgreSQL + Redis + Serverpod 통합 관리
- Terraform으로 인프라 코드화 (Infrastructure as Code)
- 환경변수 안전하게 관리 (.envrc → EC2 .env 파일)
- HTTPS 지원 (Certbot + Let's Encrypt)
- 비용 효율적인 구성 (월 ~$10, Free Tier 사용 시 ~$3)

### 성공 기준

- [ ] Terraform apply로 EC2 인스턴스 자동 생성
- [ ] Docker Compose로 PostgreSQL, Redis, Serverpod 정상 실행
- [ ] api.gear-freaks.com, insights.gear-freaks.com, app.gear-freaks.com 접속 가능
- [ ] HTTPS 인증서 정상 발급 및 적용
- [ ] DB 마이그레이션 성공적으로 실행
- [ ] Flutter 앱에서 API 호출 정상 동작
- [ ] 서버 재부팅 시 자동 재시작

---

## 2. 기술적 접근

### 아키텍처 선택

**EC2 Monolith Architecture**

```
Route53 DNS
  ↓
Elastic IP (고정 IP)
  ↓
EC2 Instance (t3.micro)
  ├── Nginx (리버스 프록시, SSL)
  └── Docker Compose
      ├── Serverpod Server (8080-8082)
      ├── PostgreSQL 16 + pgvector
      └── Redis 6.2.6
```

**왜 이 아키텍처인가?**

- **단순성**: 최소한의 AWS 리소스로 빠른 배포
- **비용**: t3.micro Free Tier 활용 가능
- **유지보수**: Docker Compose로 통합 관리
- **확장성**: 추후 Auto Scaling, RDS 전환 용이

### 사용할 도구 및 기술

#### Infrastructure

- **Terraform 1.5+**: 인프라 프로비저닝
- **AWS Provider 5.0+**: AWS 리소스 관리

#### AWS 리소스

- **EC2 Instance**: t3.micro (2 vCPU, 1GB RAM)
- **Elastic IP**: 고정 IP 할당
- **Security Group**: 방화벽 규칙
- **Route53**: DNS 레코드 (api, insights, app)
- **EBS gp3**: 20GB 루트 볼륨

#### 서버 환경

- **OS**: Amazon Linux 2023
- **Docker**: 서버 컨테이너화
- **Docker Compose**: 멀티 컨테이너 관리
- **Nginx**: 리버스 프록시
- **Certbot**: SSL/TLS 인증서 자동 발급

#### 애플리케이션

- **Serverpod 2.9.2**: Dart 백엔드 프레임워크
- **PostgreSQL 16**: pgvector 확장 포함
- **Redis 6.2.6**: 캐싱

### 파일 구조

```
deploy/aws/terraform/simple-ec2/
├── main.tf                      # EC2, Security Group, Elastic IP, Route53
├── variables.tf                 # 입력 변수 정의
├── outputs.tf                   # 출력 값 (IP, 엔드포인트 등)
├── user-data.sh                 # EC2 초기화 스크립트
├── docker-compose.production.yml # 프로덕션용 Docker Compose
├── nginx.conf.template          # Nginx 설정 템플릿
├── config.auto.tfvars           # 변수 값 (gitignore)
├── terraform.tfvars.example     # 설정 예시
└── README.md                    # 배포 가이드
```

---

## 3. 구현 단계

### Phase 0: 사전 준비 (Prerequisites)

**목표**: 배포에 필요한 사전 작업 완료

**작업 목록**:

- [ ] AWS 계정 및 CLI 설정 확인
  - AWS CLI 설치 및 자격증명 설정
  - Region: ap-northeast-2 (서울)
- [ ] SSH Key Pair 생성
  - AWS Console에서 "gear-freak-server-key" 생성
  - 또는 로컬 키를 AWS에 import
  - 키 파일 권한 설정: `chmod 400 ~/.ssh/gear-freak-server-key.pem`
- [ ] Docker 이미지 레지스트리 선택
  - Option A: Docker Hub 계정 생성
  - Option B: AWS ECR 레포지토리 생성
- [ ] 환경변수 확인
  - .envrc 파일의 모든 값 확인
  - FCM 서비스 계정 파일 존재 확인: `config/fcm-service-account.json`
  - AWS S3 버킷 접근 권한 확인

**예상 소요 시간**: 30분

**영향 받는 리소스**:

- 없음 (외부 설정)

**검증 방법**:

```bash
# AWS CLI 확인
aws sts get-caller-identity

# SSH Key 확인
aws ec2 describe-key-pairs --key-name gear-freak-server-key --region ap-northeast-2

# Docker Hub 로그인 (Option A)
docker login

# ECR 로그인 (Option B)
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com
```

**잠재적 문제**:

- AWS 자격증명 미설정 → `aws configure` 실행
- SSH Key 없음 → AWS Console에서 생성

---

### Phase 1: Docker 이미지 빌드 및 푸시

**목표**: Serverpod 서버 Docker 이미지를 레지스트리에 업로드

**작업 목록**:

- [ ] Dockerfile 검토 및 수정
  - 현재 Dockerfile은 production 모드로 빌드됨
  - EXPOSE 포트 확인 (8080, 8081, 8082)
- [ ] 로컬에서 Docker 이미지 빌드
  ```bash
  cd gear_freak_server
  docker build -t gear-freak-server:latest .
  ```
- [ ] 이미지 태그 지정
  - Docker Hub: `docker tag gear-freak-server:latest yourusername/gear-freak-server:latest`
  - ECR: `docker tag gear-freak-server:latest <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com/gear-freak-server:latest`
- [ ] 레지스트리에 푸시
  - Docker Hub: `docker push yourusername/gear-freak-server:latest`
  - ECR: `docker push <ACCOUNT_ID>.dkr.ecr.ap-northeast-2.amazonaws.com/gear-freak-server:latest`
- [ ] 이미지 pull 테스트
  ```bash
  docker pull yourusername/gear-freak-server:latest
  docker run --rm -p 8080:8080 yourusername/gear-freak-server:latest
  ```

**예상 소요 시간**: 15분

**영향 받는 파일**:

- `Dockerfile`
- Docker 레지스트리 (외부)

**의존성**:

- Phase 0 완료 필요

**검증 방법**:

- [ ] 이미지 빌드 성공 (에러 없음)
- [ ] 레지스트리에서 이미지 확인 가능
- [ ] 로컬에서 컨테이너 실행 성공

**잠재적 문제**:

- 빌드 실패 → Dockerfile 수정 또는 의존성 확인
- 푸시 권한 없음 → 레지스트리 로그인 확인
- 이미지 크기 큼 → Multi-stage build 최적화

---

### Phase 2: Terraform 파일 작성

**목표**: 인프라 코드 작성 및 검증

**작업 목록**:

#### 2.1 디렉토리 생성

```bash
mkdir -p deploy/aws/terraform/simple-ec2
cd deploy/aws/terraform/simple-ec2
```

#### 2.2 main.tf 작성

- [ ] Terraform 및 Provider 설정
  - Terraform 버전: >= 1.5.0
  - AWS Provider 버전: ~> 5.0
  - Region: ap-northeast-2
- [ ] Security Group 리소스 정의
  - 이름: `${var.project_name}-serverpod-sg`
  - Ingress 규칙:
    - SSH (22): var.admin_ip만 허용
    - HTTP (80): 0.0.0.0/0
    - HTTPS (443): 0.0.0.0/0
    - Serverpod (8080-8082): 0.0.0.0/0
  - Egress 규칙: 모든 아웃바운드 허용
- [ ] EC2 Instance 리소스 정의
  - AMI: Amazon Linux 2023 (ap-northeast-2)
  - Instance Type: t3.micro
  - Key Name: var.ssh_key_name
  - Security Group: 위에서 생성한 SG
  - Root Volume: gp3 20GB
  - User Data: templatefile로 user-data.sh 실행
  - Tags: Name = `${var.project_name}-serverpod`
- [ ] Elastic IP 리소스 정의
  - EC2 인스턴스에 연결
  - Domain: vpc
- [ ] Route53 A Records 정의
  - api.gear-freaks.com → Elastic IP
  - insights.gear-freaks.com → Elastic IP
  - app.gear-freaks.com → Elastic IP
  - TTL: 300초

#### 2.3 variables.tf 작성

- [ ] 프로젝트 설정 변수
  - project_name (기본값: "gear-freak")
  - aws_region (기본값: "ap-northeast-2")
- [ ] 인스턴스 설정 변수
  - instance_type (기본값: "t3.micro")
  - instance_ami (Amazon Linux 2023 AMI ID)
  - volume_size (기본값: 20)
- [ ] 네트워크 설정 변수
  - ssh_key_name (필수)
  - admin_ip (필수, CIDR 형식)
- [ ] 도메인 설정 변수
  - domain (기본값: "gear-freaks.com")
  - hosted_zone_id (필수)
- [ ] 환경변수 (Sensitive)
  - fcm_project_id
  - fcm_service_account_json (base64 인코딩)
  - aws_access_key_id
  - aws_secret_access_key
  - s3_public_bucket_name
  - s3_private_bucket_name
  - db_password
  - redis_password
  - docker_image_url

#### 2.4 outputs.tf 작성

- [ ] 인스턴스 정보
  - instance_id
  - public_ip (Elastic IP)
- [ ] 엔드포인트 URL
  - api_endpoint (http://api.gear-freaks.com)
  - insights_endpoint
  - web_endpoint
- [ ] SSH 접속 명령어
  - ssh_command (예: `ssh -i ~/.ssh/key.pem ec2-user@IP`)

#### 2.5 config.auto.tfvars 작성

- [ ] 민감하지 않은 설정 값
  - project_name, aws_region, instance_type 등
  - ssh_key_name, admin_ip
  - domain, hosted_zone_id
- [ ] 민감한 환경변수는 별도 관리
  - terraform.tfvars (gitignore에 추가)
  - 또는 Terraform Cloud Variables 사용

#### 2.6 terraform.tfvars.example 작성

- [ ] 설정 예시 파일
  - 모든 변수의 예시 값 포함
  - 주석으로 설명 추가
  - README에서 참조

**예상 소요 시간**: 1시간

**영향 받는 파일**:

- 새로 생성: `deploy/aws/terraform/simple-ec2/*.tf`
- 수정: `.gitignore` (terraform.tfvars 추가)

**의존성**:

- Phase 0 완료 (SSH Key, Hosted Zone ID)

**검증 방법**:

```bash
cd deploy/aws/terraform/simple-ec2

# Terraform 초기화
terraform init

# 문법 검증
terraform validate

# 포맷 확인
terraform fmt -check

# 계획 확인 (실제 적용 없이)
terraform plan
```

**예상 출력**:

- `terraform plan` 실행 시 생성될 리소스 목록 표시
- aws_instance, aws_security_group, aws_eip, aws_route53_record (3개)

**잠재적 문제**:

- AMI ID가 region에 맞지 않음 → AWS Console에서 확인
- Hosted Zone ID 잘못됨 → Route53에서 확인
- 변수 타입 불일치 → variables.tf 수정

---

### Phase 3: EC2 User Data 스크립트 작성

**목표**: EC2 인스턴스 초기화 자동화 스크립트 작성

**작업 목록**:

#### 3.1 user-data.sh 작성

- [ ] Shebang 및 에러 처리
  ```bash
  #!/bin/bash
  set -e
  exec > >(tee /var/log/user-data.log)
  exec 2>&1
  ```
- [ ] 시스템 업데이트
  ```bash
  yum update -y
  ```
- [ ] Docker 설치
  ```bash
  yum install -y docker
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ec2-user
  ```
- [ ] Docker Compose 설치
  ```bash
  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  ```
- [ ] Git 설치
  ```bash
  yum install -y git
  ```
- [ ] 서버 디렉토리 생성
  ```bash
  mkdir -p /opt/gear_freak/{config,backups}
  chown -R ec2-user:ec2-user /opt/gear_freak
  ```
- [ ] 환경변수 파일 생성
  - Terraform templatefile로 변수 주입
  ```bash
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
  DOCKER_IMAGE=${docker_image_url}
  EOF
  chmod 600 /opt/gear_freak/.env
  ```
- [ ] Docker Compose 파일 생성
  - PostgreSQL, Redis, Serverpod 서비스 정의
  - Health check 설정
  - Restart policy: unless-stopped
  - Volume 마운트: postgres_data, redis_data
- [ ] Nginx 설치 및 설정
  ```bash
  amazon-linux-extras install -y nginx1
  systemctl start nginx
  systemctl enable nginx
  ```
- [ ] Nginx 설정 파일 생성
  - 3개 서버 블록 (api, insights, app)
  - 리버스 프록시 설정
  - WebSocket 지원 (Upgrade, Connection 헤더)
  - X-Forwarded-\* 헤더 설정
- [ ] PostgreSQL 및 Redis 컨테이너 시작
  ```bash
  cd /opt/gear_freak
  docker-compose up -d postgres redis
  ```
- [ ] 초기화 완료 플래그
  ```bash
  touch /opt/gear_freak/.initialized
  echo "EC2 initialization completed at $(date)" >> /var/log/user-data.log
  ```

#### 3.2 docker-compose.production.yml 템플릿 작성

```yaml
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg16
    container_name: gear_freak_postgres
    restart: unless-stopped
    ports:
      - '5432:5432'
    environment:
      POSTGRES_USER: postgres
      POSTGRES_DB: gear_freak
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U postgres']
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:6.2.6
    container_name: gear_freak_redis
    restart: unless-stopped
    ports:
      - '6379:6379'
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    healthcheck:
      test: ['CMD', 'redis-cli', 'ping']
      interval: 10s
      timeout: 5s
      retries: 5

  serverpod:
    image: ${DOCKER_IMAGE}
    container_name: gear_freak_serverpod
    restart: unless-stopped
    ports:
      - '8080:8080'
      - '8081:8081'
      - '8082:8082'
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
    healthcheck:
      test: ['CMD', 'curl', '-f', 'http://localhost:8080']
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  postgres_data:
  redis_data:
```

#### 3.3 nginx.conf.template 작성

- [ ] api.gear-freaks.com 서버 블록
- [ ] insights.gear-freaks.com 서버 블록
- [ ] app.gear-freaks.com 서버 블록
- [ ] 공통 프록시 설정
  - proxy_pass http://localhost:PORT
  - proxy_http_version 1.1
  - WebSocket 헤더
  - X-Real-IP, X-Forwarded-For

**예상 소요 시간**: 1시간

**영향 받는 파일**:

- 새로 생성: `deploy/aws/terraform/simple-ec2/user-data.sh`
- 새로 생성: `deploy/aws/terraform/simple-ec2/docker-compose.production.yml`
- 새로 생성: `deploy/aws/terraform/simple-ec2/nginx.conf.template`

**의존성**:

- Phase 2 완료 (Terraform 변수 정의)

**검증 방법**:

- [ ] Bash 문법 검증: `bash -n user-data.sh`
- [ ] Docker Compose 문법 검증: `docker-compose -f docker-compose.production.yml config`
- [ ] Nginx 설정 검증: `nginx -t -c nginx.conf.template` (로컬에서)

**잠재적 문제**:

- 환경변수 치환 실패 → Terraform templatefile 함수 확인
- Docker Compose 버전 불일치 → 최신 버전 설치
- Nginx 설정 오류 → 문법 확인

---

### Phase 4: Terraform Apply 및 인프라 배포

**목표**: AWS 리소스 생성 및 EC2 인스턴스 초기화

**작업 목록**:

#### 4.1 Terraform 실행 전 최종 확인

- [ ] config.auto.tfvars 모든 값 입력 확인
  - ssh_key_name (실제 키 이름)
  - admin_ip (본인 IP/32)
  - hosted_zone_id (Route53 Zone ID)
- [ ] terraform.tfvars 민감 정보 입력
  - fcm_project_id
  - aws_access_key_id, aws_secret_access_key
  - db_password, redis_password
  - docker_image_url
- [ ] .gitignore 확인
  - terraform.tfvars 포함 여부
  - .terraform/ 폴더 제외

#### 4.2 Terraform 초기화 및 계획

```bash
cd deploy/aws/terraform/simple-ec2

# 초기화
terraform init

# 계획 확인
terraform plan -out=tfplan

# 계획 검토
# - aws_instance.serverpod (EC2)
# - aws_security_group.serverpod
# - aws_eip.serverpod
# - aws_route53_record.api
# - aws_route53_record.insights
# - aws_route53_record.web
```

#### 4.3 Terraform Apply

```bash
# 실행
terraform apply tfplan

# 또는 자동 승인
terraform apply -auto-approve
```

#### 4.4 출력 값 확인

```bash
terraform output

# 예상 출력:
# instance_id = "i-0123456789abcdef0"
# public_ip = "54.180.XXX.XXX"
# api_endpoint = "http://api.gear-freaks.com"
# insights_endpoint = "http://insights.gear-freaks.com"
# web_endpoint = "http://app.gear-freaks.com"
# ssh_command = "ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@54.180.XXX.XXX"
```

#### 4.5 EC2 초기화 대기

- [ ] EC2 Status Check 확인 (2/2 passed)
  ```bash
  aws ec2 describe-instance-status --instance-ids $(terraform output -raw instance_id)
  ```
- [ ] User Data 로그 확인 (SSH 접속)

  ```bash
  ELASTIC_IP=$(terraform output -raw public_ip)
  ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@$ELASTIC_IP

  # 로그 확인
  tail -f /var/log/user-data.log

  # Docker 상태
  docker ps

  # PostgreSQL, Redis 실행 확인
  docker-compose -f /opt/gear_freak/docker-compose.yml ps
  ```

**예상 소요 시간**: 30분 (EC2 초기화 포함)

**영향 받는 리소스**:

- AWS 리소스: EC2, Security Group, Elastic IP, Route53 Records

**의존성**:

- Phase 0, 1, 2, 3 완료

**검증 방법**:

- [ ] `terraform apply` 성공 (에러 없음)
- [ ] AWS Console에서 EC2 인스턴스 확인
- [ ] Elastic IP 연결 확인
- [ ] Route53 A 레코드 생성 확인
- [ ] SSH 접속 성공
- [ ] Docker 및 Docker Compose 설치 확인
- [ ] PostgreSQL, Redis 컨테이너 실행 중

**예상 비용**:

- EC2 t3.micro: ~$7.50/월 (Free Tier: 무료)
- EBS gp3 20GB: ~$2.00/월
- Elastic IP (연결됨): $0
- Route53 쿼리: ~$0.40/월
- **총합**: ~$10/월 (Free Tier: ~$3/월)

**잠재적 문제**:

- SSH 연결 실패 → Security Group 규칙 확인, admin_ip 확인
- User Data 실행 실패 → /var/log/user-data.log 확인
- Docker 설치 실패 → Amazon Linux 2023 AMI 확인

---

### Phase 5: Serverpod 서버 배포 및 설정

**목표**: Serverpod 컨테이너 실행 및 DB 마이그레이션

**작업 목록**:

#### 5.1 FCM 서비스 계정 파일 업로드

```bash
ELASTIC_IP=$(terraform output -raw public_ip)

# FCM 서비스 계정 파일 업로드
scp -i ~/.ssh/gear-freak-server-key.pem \
    ../../config/fcm-service-account.json \
    ec2-user@$ELASTIC_IP:/opt/gear_freak/config/

# 권한 설정
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@$ELASTIC_IP
chmod 600 /opt/gear_freak/config/fcm-service-account.json
```

#### 5.2 production.yaml 수정

- [ ] SSH로 EC2 접속
- [ ] config/production.yaml 수정 (또는 로컬에서 수정 후 업로드)

  ```yaml
  apiServer:
    port: 8080
    publicHost: api.gear-freaks.com
    publicPort: 443
    publicScheme: https

  insightsServer:
    port: 8081
    publicHost: insights.gear-freaks.com
    publicPort: 443
    publicScheme: https

  webServer:
    port: 8082
    publicHost: app.gear-freaks.com
    publicPort: 443
    publicScheme: https

  database:
    host: localhost # Docker Compose의 postgres 서비스
    port: 5432
    name: gear_freak
    user: postgres
    requireSsl: false # 로컬 연결이므로 false

  redis:
    enabled: true
    host: localhost # Docker Compose의 redis 서비스
    port: 6379
    requireSsl: false

  maxRequestSize: 524288

  sessionLogs:
    consoleEnabled: false
  ```

- [ ] 파일 업로드 (수정한 경우)
  ```bash
  scp -i ~/.ssh/gear-freak-server-key.pem \
      config/production.yaml \
      ec2-user@$ELASTIC_IP:/opt/gear_freak/config/
  ```

#### 5.3 passwords.yaml 확인

- [ ] EC2의 /opt/gear_freak/config/passwords.yaml 확인
- [ ] production 섹션의 비밀번호가 .env 파일과 일치하는지 확인
- [ ] 필요 시 수정
  ```yaml
  production:
    database: '<POSTGRES_PASSWORD from .env>'
    redis: '<REDIS_PASSWORD from .env>'
  ```

#### 5.4 Docker Compose 파일 확인 및 수정

```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@$ELASTIC_IP

cd /opt/gear_freak

# docker-compose.yml 확인
cat docker-compose.yml

# serverpod 서비스의 image 확인
# image: yourusername/gear-freak-server:latest (또는 ECR URL)

# 필요 시 이미지 URL 수정
vi docker-compose.yml
```

#### 5.5 Serverpod 컨테이너 시작

```bash
cd /opt/gear_freak

# 환경변수와 함께 실행
docker-compose up -d serverpod

# 로그 확인
docker-compose logs -f serverpod

# 예상 로그:
# - Connecting to database...
# - Database connection established
# - Serverpod server started on port 8080
```

#### 5.6 DB 마이그레이션 실행

```bash
# Serverpod 컨테이너 접속
docker exec -it gear_freak_serverpod sh

# 마이그레이션 실행
./server --apply-migrations

# 성공 메시지 확인:
# - Migration XXX applied successfully

# 컨테이너 종료
exit

# Serverpod 재시작
docker-compose restart serverpod
```

#### 5.7 전체 서비스 상태 확인

```bash
# 모든 컨테이너 상태
docker-compose ps

# 예상 출력:
#         Name                    State           Ports
# gear_freak_postgres    Up (healthy)   5432/tcp
# gear_freak_redis       Up (healthy)   6379/tcp
# gear_freak_serverpod   Up (healthy)   8080-8082/tcp

# 로그 모니터링
docker-compose logs -f

# Ctrl+C로 종료
```

**예상 소요 시간**: 30분

**영향 받는 파일**:

- EC2: `/opt/gear_freak/config/production.yaml`
- EC2: `/opt/gear_freak/config/fcm-service-account.json`
- EC2: `/opt/gear_freak/config/passwords.yaml`

**의존성**:

- Phase 4 완료 (EC2 인스턴스 실행 중)
- Phase 1 완료 (Docker 이미지 존재)

**검증 방법**:

- [ ] FCM 파일 업로드 성공
- [ ] Docker Compose에서 serverpod 컨테이너 실행 중
- [ ] 마이그레이션 성공 (에러 없음)
- [ ] Health check 통과 (docker ps에서 healthy 상태)
- [ ] 로그에 에러 없음

**잠재적 문제**:

- DB 연결 실패 → production.yaml의 database host 확인 (localhost여야 함)
- Redis 연결 실패 → passwords.yaml의 redis 비밀번호 확인
- 마이그레이션 실패 → 로그 확인, DB 상태 확인
- 이미지 pull 실패 → Docker Hub/ECR 로그인 확인

---

### Phase 6: Nginx 및 SSL 설정

**목표**: HTTPS 인증서 발급 및 리버스 프록시 설정

**작업 목록**:

#### 6.1 DNS 전파 확인

```bash
# 로컬에서 DNS 확인
dig api.gear-freaks.com +short
dig insights.gear-freaks.com +short
dig app.gear-freaks.com +short

# Elastic IP와 일치하는지 확인
terraform output -raw public_ip

# DNS 전파 대기 (최대 5분)
```

#### 6.2 HTTP 접속 테스트

```bash
# API 서버 테스트
curl http://api.gear-freaks.com

# 예상: Nginx 502 Bad Gateway 또는 Serverpod 응답

# Insights 테스트 (브라우저)
open http://insights.gear-freaks.com
```

#### 6.3 Certbot 설치

```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@$ELASTIC_IP

# Certbot 및 Nginx 플러그인 설치
sudo yum install -y certbot python3-certbot-nginx
```

#### 6.4 SSL 인증서 발급

```bash
# 3개 도메인에 대해 인증서 발급
sudo certbot --nginx \
  -d api.gear-freaks.com \
  -d insights.gear-freaks.com \
  -d app.gear-freaks.com \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email \
  --redirect

# 인터랙티브 프롬프트:
# - 이메일 확인
# - 이용 약관 동의
# - HTTP → HTTPS 리다이렉트 설정 (Y)

# 성공 메시지:
# - Successfully received certificate.
# - Certificate is saved at: /etc/letsencrypt/live/api.gear-freaks.com/fullchain.pem
# - Your key file has been saved at: /etc/letsencrypt/live/api.gear-freaks.com/privkey.pem
```

#### 6.5 Nginx 설정 확인

```bash
# Certbot이 자동으로 수정한 설정 확인
sudo cat /etc/nginx/conf.d/serverpod.conf

# 예상 내용:
# - HTTP (80) 서버 블록: HTTPS로 리다이렉트
# - HTTPS (443) 서버 블록: proxy_pass 설정
# - SSL 인증서 경로

# Nginx 재시작
sudo systemctl reload nginx

# 상태 확인
sudo systemctl status nginx
```

#### 6.6 자동 갱신 설정

```bash
# Certbot 타이머 활성화 (systemd)
sudo systemctl enable certbot-renew.timer
sudo systemctl start certbot-renew.timer

# 타이머 상태 확인
sudo systemctl list-timers | grep certbot

# 수동 갱신 테스트 (dry-run)
sudo certbot renew --dry-run

# 성공 메시지:
# - Cert not yet due for renewal
# - The dry run was successful.
```

**예상 소요 시간**: 20분

**영향 받는 파일**:

- EC2: `/etc/nginx/conf.d/serverpod.conf` (Certbot이 수정)
- EC2: `/etc/letsencrypt/live/api.gear-freaks.com/*` (인증서 파일)

**의존성**:

- Phase 5 완료 (Serverpod 실행 중)
- DNS 전파 완료

**검증 방법**:

```bash
# HTTPS 접속 테스트
curl https://api.gear-freaks.com

# 인증서 확인
curl -vI https://api.gear-freaks.com 2>&1 | grep "subject:"

# 브라우저 테스트
open https://insights.gear-freaks.com
open https://app.gear-freaks.com

# SSL Labs 테스트 (선택)
open https://www.ssllabs.com/ssltest/analyze.html?d=api.gear-freaks.com
```

**예상 결과**:

- [ ] HTTPS 접속 성공 (자물쇠 아이콘)
- [ ] 인증서 유효 (Let's Encrypt)
- [ ] HTTP → HTTPS 리다이렉트 동작
- [ ] SSL Labs Grade A 이상

**잠재적 문제**:

- DNS 전파 안 됨 → Route53 레코드 확인, TTL 대기
- Certbot 실패 → 80, 443 포트 오픈 확인, Security Group 확인
- Nginx 오류 → `sudo nginx -t` 문법 확인
- 인증서 갱신 실패 → cron job 또는 systemd timer 확인

---

### Phase 7: 엔드투엔드 테스트

**목표**: 전체 시스템 동작 검증

**작업 목록**:

#### 7.1 API 엔드포인트 테스트

```bash
# Health check (커스텀 엔드포인트가 있다면)
curl https://api.gear-freaks.com/health

# 인증 없이 접근 가능한 엔드포인트 테스트
curl https://api.gear-freaks.com/

# 예상: Serverpod 기본 응답 또는 404
```

#### 7.2 Flutter 앱 연동 테스트

- [ ] Flutter 앱의 BASE_URL 수정
  - .env 파일: `BASE_URL=https://api.gear-freaks.com`
- [ ] 앱 재빌드 및 실행
  ```bash
  cd gear_freak_flutter
  flutter clean
  flutter pub get
  flutter run
  ```
- [ ] 로그인 테스트
  - Kakao, Naver, Google, Apple 로그인 시도
  - 성공 시 유저 정보 확인
- [ ] 상품 목록 조회
  - 홈 화면에서 상품 리스트 로딩
- [ ] 이미지 업로드 테스트
  - 새 상품 등록
  - S3 업로드 성공 확인
- [ ] 채팅 테스트
  - 메시지 전송
  - 실시간 메시지 수신 확인
- [ ] FCM 푸시 알림 테스트
  - 백그라운드에서 알림 수신 확인

#### 7.3 Insights 대시보드 테스트

```bash
# 브라우저에서 접속
open https://insights.gear-freaks.com

# 로그 확인
# - API 호출 통계
# - 에러 로그
# - 성능 메트릭
```

#### 7.4 DB 및 Redis 연결 테스트

```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@$ELASTIC_IP

cd /opt/gear_freak

# PostgreSQL 접속
docker exec -it gear_freak_postgres psql -U postgres -d gear_freak

# 테이블 확인
\dt

# 유저 카운트
SELECT COUNT(*) FROM serverpod_user_info;

# 종료
\q

# Redis 접속
docker exec -it gear_freak_redis redis-cli -a <REDIS_PASSWORD>

# 키 확인
KEYS *

# 종료
exit
```

#### 7.5 로그 모니터링

```bash
# 모든 컨테이너 로그
docker-compose logs -f

# Serverpod만
docker-compose logs -f serverpod

# Nginx 로그
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# 시스템 로그
journalctl -u docker -f
```

**예상 소요 시간**: 1시간

**의존성**:

- Phase 6 완료 (HTTPS 설정)

**검증 방법**:

- [ ] API 호출 성공 (200 OK)
- [ ] Flutter 앱 로그인 성공
- [ ] 상품 CRUD 정상 동작
- [ ] 채팅 실시간 메시지 전송/수신
- [ ] FCM 푸시 알림 수신
- [ ] Insights 대시보드 접속 성공
- [ ] DB 데이터 정상 저장
- [ ] Redis 캐싱 동작
- [ ] 로그에 CRITICAL/ERROR 없음

**잠재적 문제**:

- API 호출 실패 → Nginx 설정, Serverpod 로그 확인
- CORS 에러 → Serverpod CORS 설정 확인
- 이미지 업로드 실패 → S3 권한 확인, 환경변수 확인
- FCM 실패 → fcm-service-account.json 확인
- 채팅 연결 실패 → WebSocket 프록시 설정 확인

---

### Phase 8: 운영 환경 최적화 및 모니터링 설정

**목표**: 프로덕션 환경 안정화 및 모니터링 구축

**작업 목록**:

#### 8.1 자동 백업 스크립트 설정

- [ ] 백업 스크립트 작성

  ```bash
  ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@$ELASTIC_IP

  sudo vi /opt/gear_freak/backup.sh
  ```

  ```bash
  #!/bin/bash
  BACKUP_DIR="/opt/gear_freak/backups"
  DATE=$(date +%Y%m%d_%H%M%S)
  BACKUP_FILE="$BACKUP_DIR/postgres_$DATE.sql"

  mkdir -p $BACKUP_DIR

  # PostgreSQL 백업
  docker exec gear_freak_postgres pg_dump -U postgres gear_freak > $BACKUP_FILE

  # 압축
  gzip $BACKUP_FILE

  # S3 업로드
  aws s3 cp ${BACKUP_FILE}.gz s3://gear-freak-private-storage-3059875/backups/

  # 로컬 7일 이상 백업 삭제
  find $BACKUP_DIR -name "postgres_*.sql.gz" -mtime +7 -delete

  echo "Backup completed: ${BACKUP_FILE}.gz"
  ```

- [ ] 실행 권한 부여

  ```bash
  chmod +x /opt/gear_freak/backup.sh
  ```

- [ ] Cron 설정

  ```bash
  crontab -e

  # 매일 새벽 3시 백업
  0 3 * * * /opt/gear_freak/backup.sh >> /var/log/backup.log 2>&1
  ```

- [ ] 백업 테스트
  ```bash
  /opt/gear_freak/backup.sh
  ls -lh /opt/gear_freak/backups/
  aws s3 ls s3://gear-freak-private-storage-3059875/backups/
  ```

#### 8.2 CloudWatch 모니터링 설정

- [ ] CloudWatch Agent 설치 (선택)

  ```bash
  sudo yum install -y amazon-cloudwatch-agent
  ```

- [ ] 기본 메트릭 확인

  - AWS Console → CloudWatch → Metrics → EC2
  - CPUUtilization, NetworkIn, NetworkOut
  - DiskReadBytes, DiskWriteBytes

- [ ] CloudWatch 알람 생성 (선택)
  ```bash
  # CPU 사용률 80% 이상 알람
  aws cloudwatch put-metric-alarm \
    --alarm-name gear-freak-high-cpu \
    --alarm-description "CPU usage above 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --dimensions Name=InstanceId,Value=$(terraform output -raw instance_id) \
    --alarm-actions <SNS_TOPIC_ARN>
  ```

#### 8.3 로그 로테이션 설정

- [ ] logrotate 설정

  ```bash
  sudo vi /etc/logrotate.d/gear_freak
  ```

  ```
  /var/log/nginx/*.log {
      daily
      missingok
      rotate 14
      compress
      delaycompress
      notifempty
      create 0640 nginx nginx
      sharedscripts
      postrotate
          systemctl reload nginx
      endscript
  }

  /opt/gear_freak/backups/*.log {
      weekly
      rotate 4
      compress
      missingok
  }
  ```

#### 8.4 서버 재부팅 시 자동 시작 설정

- [ ] Docker Compose systemd 서비스 생성

  ```bash
  sudo vi /etc/systemd/system/gear-freak.service
  ```

  ```ini
  [Unit]
  Description=Gear Freak Serverpod
  Requires=docker.service
  After=docker.service

  [Service]
  Type=oneshot
  RemainAfterExit=yes
  WorkingDirectory=/opt/gear_freak
  ExecStart=/usr/local/bin/docker-compose up -d
  ExecStop=/usr/local/bin/docker-compose down
  User=ec2-user

  [Install]
  WantedBy=multi-user.target
  ```

- [ ] 서비스 활성화

  ```bash
  sudo systemctl enable gear-freak.service
  sudo systemctl start gear-freak.service
  sudo systemctl status gear-freak.service
  ```

- [ ] 재부팅 테스트

  ```bash
  sudo reboot

  # 재부팅 후 SSH 재접속
  ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@$ELASTIC_IP

  # 서비스 확인
  docker-compose ps
  curl https://api.gear-freaks.com
  ```

#### 8.5 보안 강화

- [ ] SSH 포트 변경 (선택)

  ```bash
  sudo vi /etc/ssh/sshd_config
  # Port 2222 (예시)

  sudo systemctl restart sshd
  ```

- [ ] fail2ban 설치 (선택)

  ```bash
  sudo yum install -y fail2ban
  sudo systemctl enable fail2ban
  sudo systemctl start fail2ban
  ```

- [ ] 정기적인 시스템 업데이트 스케줄

  ```bash
  crontab -e

  # 매주 일요일 새벽 2시 업데이트 (자동 재부팅 없음)
  0 2 * * 0 sudo yum update -y >> /var/log/yum-update.log 2>&1
  ```

**예상 소요 시간**: 1시간

**영향 받는 파일**:

- EC2: `/opt/gear_freak/backup.sh`
- EC2: `/etc/systemd/system/gear-freak.service`
- EC2: `/etc/logrotate.d/gear_freak`
- EC2: `/etc/crontab` (백업, 업데이트)

**의존성**:

- Phase 7 완료 (시스템 정상 동작)

**검증 방법**:

- [ ] 백업 스크립트 실행 성공
- [ ] S3에 백업 파일 업로드 확인
- [ ] Cron 작업 등록 확인: `crontab -l`
- [ ] CloudWatch 메트릭 데이터 수신 확인
- [ ] 재부팅 후 자동 시작 확인
- [ ] 로그 로테이션 동작 확인

**잠재적 문제**:

- 백업 실패 → PostgreSQL 컨테이너 상태, S3 권한 확인
- Cron 실행 안 됨 → crond 서비스 상태 확인
- systemd 서비스 실패 → journalctl 로그 확인
- 재부팅 후 서비스 안 뜸 → systemctl enable 확인

---

### Phase 9: 문서화 및 README 작성

**목표**: 배포 과정 및 운영 가이드 문서화

**작업 목록**:

#### 9.1 deploy/aws/terraform/simple-ec2/README.md 작성

- [ ] 프로젝트 개요
- [ ] 사전 요구사항
  - AWS 계정
  - Terraform 1.5+
  - SSH Key Pair
  - Docker Hub 또는 ECR
- [ ] 배포 단계
  1. SSH Key 생성
  2. Docker 이미지 빌드 및 푸시
  3. config.auto.tfvars 설정
  4. terraform init & apply
  5. FCM 파일 업로드
  6. Serverpod 서버 시작
  7. SSL 인증서 발급
- [ ] 운영 가이드
  - 서버 접속 방법
  - 로그 확인 방법
  - 백업 확인 방법
  - 업데이트 배포 방법
- [ ] 트러블슈팅
  - 일반적인 문제 및 해결 방법
- [ ] 비용 정보
- [ ] 참고 자료

#### 9.2 terraform.tfvars.example 작성

```hcl
# 프로젝트 설정
project_name = "gear-freak"
aws_region = "ap-northeast-2"

# 인스턴스 설정
instance_type = "t3.micro"
instance_ami = "ami-0c9c942bd7bf113a2"  # Amazon Linux 2023 (ap-northeast-2)
volume_size = 20

# 네트워크 설정
ssh_key_name = "gear-freak-server-key"  # AWS Key Pair 이름
admin_ip = "YOUR_IP_ADDRESS/32"         # 본인 IP (예: 1.2.3.4/32)

# 도메인 설정
domain = "gear-freaks.com"
hosted_zone_id = "Z0891796X4J567MSHFSJ"

# 환경변수 (민감 정보 - terraform.tfvars에 작성)
# fcm_project_id = "gear-freak"
# aws_access_key_id = "YOUR_AWS_KEY"
# aws_secret_access_key = "YOUR_AWS_SECRET"
# s3_public_bucket_name = "gear-freak-public-storage-3059875"
# s3_private_bucket_name = "gear-freak-private-storage-3059875"
# db_password = "STRONG_PASSWORD"
# redis_password = "STRONG_PASSWORD"
# docker_image_url = "yourusername/gear-freak-server:latest"
```

#### 9.3 운영 체크리스트 작성

- [ ] OPERATIONS.md 작성
  - 일일 체크 항목
  - 주간 체크 항목
  - 월간 체크 항목
  - 백업 확인
  - 보안 업데이트
  - 모니터링 검토

#### 9.4 주석 및 코드 정리

- [ ] main.tf, variables.tf, outputs.tf 주석 추가
- [ ] user-data.sh 주석 보강
- [ ] docker-compose.production.yml 주석 추가

**예상 소요 시간**: 1시간

**영향 받는 파일**:

- 새로 생성: `deploy/aws/terraform/simple-ec2/README.md`
- 새로 생성: `deploy/aws/terraform/simple-ec2/OPERATIONS.md`
- 새로 생성: `deploy/aws/terraform/simple-ec2/terraform.tfvars.example`
- 수정: 모든 .tf 파일 (주석 추가)

**검증 방법**:

- [ ] README.md 가독성 확인
- [ ] 배포 단계 따라하기 테스트 (신규 팀원 관점)
- [ ] 링크 및 명령어 정확성 확인

---

## 4. 리스크 및 대응 방안

### 리스크 1: 메모리 부족 (t3.micro 1GB RAM)

- **확률**: Medium
- **영향도**: High
- **증상**: OOM Killer, 컨테이너 재시작, 응답 속도 저하
- **완화 방안**:
  - Swap 메모리 추가 (1GB)
  ```bash
  sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  ```
  - 트래픽 증가 시 t3.small (2GB RAM)로 업그레이드
  - Docker Compose 리소스 제한 설정
  ```yaml
  serverpod:
    deploy:
      resources:
        limits:
          memory: 512M
  ```

### 리스크 2: 단일 장애점 (Single Point of Failure)

- **확률**: Low
- **영향도**: High
- **증상**: EC2 장애 시 전체 서비스 중단
- **완화 방안**:
  - 정기적인 백업 (매일 새벽 3시)
  - EBS 스냅샷 자동화
  - 향후 Auto Scaling Group + ALB로 전환
  - 중요 이벤트 시 수동 스냅샷 생성

### 리스크 3: SSL 인증서 갱신 실패

- **확률**: Low
- **영향도**: Medium
- **증상**: HTTPS 접속 불가, 브라우저 경고
- **완화 방안**:
  - Certbot 자동 갱신 타이머 활성화 (systemd)
  - 만료 30일 전 알림 설정
  - 수동 갱신 절차 문서화
  ```bash
  sudo certbot renew --force-renewal
  sudo systemctl reload nginx
  ```

### 리스크 4: Docker 이미지 빌드 실패

- **확률**: Medium
- **영향도**: High
- **증상**: 새 버전 배포 불가
- **완화 방안**:
  - 로컬 빌드 테스트 후 푸시
  - 이전 버전 이미지 태그 유지 (롤백 가능)
  - CI/CD 파이프라인 구축 (향후)
  - 빌드 로그 저장 및 검토

### 리스크 5: 환경변수 노출

- **확률**: Low
- **영향도**: Critical
- **증상**: 민감 정보 유출, 보안 침해
- **완화 방안**:
  - terraform.tfvars를 .gitignore에 추가
  - EC2 .env 파일 권한 600 설정
  - Terraform Cloud Sensitive Variables 사용
  - AWS Secrets Manager로 전환 (향후)
  - 정기적인 비밀번호 로테이션

### 리스크 6: 비용 초과

- **확률**: Low
- **영향도**: Medium
- **증상**: 예상보다 높은 AWS 청구서
- **완화 방안**:
  - AWS Cost Explorer 모니터링
  - CloudWatch Billing 알람 설정 (월 $20 초과 시)
  ```bash
  aws cloudwatch put-metric-alarm \
    --alarm-name billing-alarm \
    --metric-name EstimatedCharges \
    --namespace AWS/Billing \
    --statistic Maximum \
    --period 21600 \
    --threshold 20 \
    --comparison-operator GreaterThanThreshold
  ```
  - Free Tier 사용량 추적
  - 불필요한 리소스 정리 (EBS 스냅샷, Elastic IP 등)

### 리스크 7: DB 데이터 손실

- **확률**: Low
- **영향도**: Critical
- **증상**: 유저 데이터, 상품 정보 손실
- **완화 방안**:
  - 매일 자동 백업 (pg_dump)
  - S3 백업 파일 버전 관리 활성화
  - 백업 복원 테스트 (월 1회)
  ```bash
  # 복원 테스트
  docker exec -i gear_freak_postgres psql -U postgres -d gear_freak_test < backup.sql
  ```
  - 향후 RDS 전환 시 자동 백업 활용

---

## 5. 전체 검증 계획

### 5.1 자동 테스트 (해당 시 작성)

현재 프로젝트는 인프라 배포이므로 자동 테스트가 제한적입니다. 향후 추가할 수 있는 테스트:

- [ ] Terraform Plan 테스트
  ```bash
  terraform plan -detailed-exitcode
  # Exit code 0: 변경 없음, 2: 변경 있음
  ```
- [ ] user-data.sh Bash 문법 검증
  ```bash
  bash -n user-data.sh
  shellcheck user-data.sh
  ```
- [ ] Docker Compose 설정 검증
  ```bash
  docker-compose -f docker-compose.production.yml config
  ```

### 5.2 수동 테스트 시나리오

#### 시나리오 1: 신규 배포 (Fresh Deploy)

1. [ ] Terraform으로 EC2 생성
2. [ ] SSH 접속 확인
3. [ ] Docker, Docker Compose 설치 확인
4. [ ] PostgreSQL, Redis 컨테이너 실행 확인
5. [ ] FCM 파일 업로드
6. [ ] Serverpod 컨테이너 시작
7. [ ] DB 마이그레이션 실행
8. [ ] SSL 인증서 발급
9. [ ] HTTPS 접속 확인
10. [ ] Flutter 앱에서 API 호출 테스트

#### 시나리오 2: 서버 업데이트

1. [ ] 새 Docker 이미지 빌드 및 푸시
2. [ ] EC2 SSH 접속
3. [ ] docker-compose.yml 이미지 태그 수정
4. [ ] `docker-compose pull serverpod`
5. [ ] `docker-compose up -d serverpod`
6. [ ] Health check 확인
7. [ ] API 동작 확인

#### 시나리오 3: 서버 재부팅

1. [ ] `sudo reboot` 실행
2. [ ] 1-2분 대기
3. [ ] SSH 재접속
4. [ ] systemd 서비스로 자동 시작 확인
5. [ ] 모든 컨테이너 실행 중 확인
6. [ ] API, Insights, Web 접속 확인

#### 시나리오 4: 백업 및 복원

1. [ ] 수동 백업 실행: `/opt/gear_freak/backup.sh`
2. [ ] S3에 백업 파일 확인
3. [ ] 백업 파일 다운로드
4. [ ] 테스트 DB에 복원
5. [ ] 데이터 무결성 확인

#### 시나리오 5: 장애 복구

1. [ ] Serverpod 컨테이너 강제 종료
2. [ ] Docker Compose restart로 복구
3. [ ] 로그 확인
4. [ ] API 동작 확인

### 5.3 성능 체크

#### 리소스 사용량

- [ ] CPU 사용률 < 70% (idle)
- [ ] Memory 사용량 < 80% (700MB/1GB)
- [ ] Disk 사용량 < 50% (10GB/20GB)
- [ ] Network I/O 정상 범위

#### 응답 속도

- [ ] API 응답 시간 < 500ms (간단한 GET 요청)
- [ ] DB 쿼리 시간 < 100ms (단순 SELECT)
- [ ] 이미지 업로드 시간 < 3초 (1MB 파일)

#### 동시 사용자

- [ ] 10명 동시 접속 처리 가능
- [ ] 초당 50 요청 처리 가능 (간단한 API)

### 5.4 보안 체크

- [ ] SSH 포트 22 접근: admin_ip만 허용
- [ ] HTTP 포트 80: HTTPS로 리다이렉트
- [ ] HTTPS 포트 443: SSL 인증서 유효
- [ ] Serverpod 포트 8080-8082: Nginx 프록시 뒤에 숨김
- [ ] PostgreSQL 포트 5432: 외부 접근 불가 (localhost만)
- [ ] Redis 포트 6379: 외부 접근 불가, 비밀번호 설정
- [ ] .env 파일 권한: 600 (소유자만 읽기/쓰기)
- [ ] terraform.tfvars: .gitignore에 포함

### 5.6 배포 후 체크리스트

- [ ] Terraform state 백업 (S3 backend 설정)
- [ ] AWS 태그 설정 (Environment: production, Project: gear-freak)
- [ ] CloudWatch 알람 생성 (CPU, Memory, Disk)
- [ ] 백업 스크립트 동작 확인
- [ ] SSL 인증서 만료일 확인 (90일)
- [ ] 모니터링 대시보드 설정 (CloudWatch 또는 Grafana)
- [ ] 운영 문서 업데이트
- [ ] 팀원에게 접근 권한 부여 (SSH Key, AWS Console)

---

## 6. 다음 단계 (Post-Deployment)

### 단기 개선 (1-2주)

1. [ ] CloudWatch 대시보드 구축
2. [ ] Slack/이메일 알람 연동
3. [ ] 성능 모니터링 및 최적화
4. [ ] 로그 분석 자동화

### 중기 개선 (1-3개월)

1. [ ] CI/CD 파이프라인 구축 (GitHub Actions)
2. [ ] Blue-Green Deployment
3. [ ] RDS PostgreSQL 전환 (DB 분리)
4. [ ] ElastiCache Redis 전환 (캐시 분리)
5. [ ] Application Load Balancer 도입

### 장기 개선 (3-6개월)

1. [ ] Auto Scaling Group (수평 확장)
2. [ ] Multi-AZ 배포 (고가용성)
3. [ ] CloudFront CDN 활용 (글로벌 배포)
4. [ ] Kubernetes 전환 (컨테이너 오케스트레이션)

---

## 7. 참고 자료

### 공식 문서

- [Serverpod Deployment Guide](https://docs.serverpod.dev/deployment)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Let's Encrypt Certbot](https://certbot.eff.org/)

### 내부 문서

- 연구 문서: `thoughts/shared/research/aws_ec2_deployment_strategy_2026-01-12.md`
- 프로젝트 가이드: `CLAUDE.md`
- 서버 명령어: `COMMANDS.md`

### 유용한 명령어 치트시트

#### Terraform

```bash
terraform init          # 초기화
terraform validate      # 문법 검증
terraform plan          # 실행 계획 확인
terraform apply         # 인프라 배포
terraform destroy       # 인프라 삭제
terraform output        # 출력 값 확인
terraform state list    # 리소스 목록
```

#### Docker & Docker Compose

```bash
docker ps                              # 실행 중인 컨테이너
docker logs -f <container>             # 로그 실시간 확인
docker exec -it <container> sh         # 컨테이너 접속
docker-compose up -d                   # 백그라운드 실행
docker-compose down                    # 컨테이너 중지 및 삭제
docker-compose restart <service>       # 서비스 재시작
docker-compose logs -f <service>       # 서비스 로그
docker stats                           # 리소스 사용량
```

#### AWS CLI

```bash
aws ec2 describe-instances                              # EC2 목록
aws ec2 describe-instance-status --instance-ids <ID>    # 상태 확인
aws s3 ls s3://bucket-name                              # S3 버킷 내용
aws route53 list-resource-record-sets --hosted-zone-id <ID>  # DNS 레코드
```

#### System

```bash
sudo systemctl status <service>     # 서비스 상태
sudo journalctl -u <service> -f     # systemd 로그
htop                                # 리소스 모니터링
df -h                               # 디스크 사용량
free -h                             # 메모리 사용량
netstat -tulpn                      # 포트 확인
```

---

## 8. 예상 일정

| Phase   | 작업 내용                  | 예상 시간 | 누적 시간  |
| ------- | -------------------------- | --------- | ---------- |
| Phase 0 | 사전 준비                  | 30분      | 30분       |
| Phase 1 | Docker 이미지 빌드 및 푸시 | 15분      | 45분       |
| Phase 2 | Terraform 파일 작성        | 1시간     | 1시간 45분 |
| Phase 3 | User Data 스크립트 작성    | 1시간     | 2시간 45분 |
| Phase 4 | Terraform Apply            | 30분      | 3시간 15분 |
| Phase 5 | Serverpod 배포 및 설정     | 30분      | 3시간 45분 |
| Phase 6 | Nginx 및 SSL 설정          | 20분      | 4시간 5분  |
| Phase 7 | 엔드투엔드 테스트          | 1시간     | 5시간 5분  |
| Phase 8 | 운영 환경 최적화           | 1시간     | 6시간 5분  |
| Phase 9 | 문서화                     | 1시간     | 7시간 5분  |

**총 예상 시간**: 약 7시간

**실제 소요 시간**: 8-10시간 (트러블슈팅 포함)

**권장 일정**:

- Day 1 (3시간): Phase 0-3 (준비 및 코드 작성)
- Day 2 (2시간): Phase 4-5 (배포 및 서버 설정)
- Day 3 (2시간): Phase 6-7 (SSL 및 테스트)
- Day 4 (2시간): Phase 8-9 (최적화 및 문서화)

---

## 9. 성공 기준 최종 확인

배포가 성공적으로 완료되었다고 판단하는 기준:

### 필수 기준

- [x] Terraform apply 성공 (모든 리소스 생성)
- [x] EC2 인스턴스 실행 중 (Status Check 2/2)
- [x] Docker Compose로 3개 컨테이너 실행 (postgres, redis, serverpod)
- [x] HTTPS 인증서 발급 및 적용
- [x] https://api.gear-freaks.com 접속 가능
- [x] https://insights.gear-freaks.com 접속 가능
- [x] https://app.gear-freaks.com 접속 가능
- [x] Flutter 앱에서 API 호출 성공
- [x] DB 마이그레이션 완료 (테이블 생성)
- [x] 서버 재부팅 후 자동 재시작

### 권장 기준

- [ ] CloudWatch 모니터링 설정
- [ ] 자동 백업 스크립트 동작
- [ ] S3에 백업 파일 업로드 확인
- [ ] SSL 자동 갱신 설정
- [ ] 운영 문서 작성 완료
- [ ] 팀원 교육 완료

### 성능 기준

- [ ] API 응답 시간 < 500ms
- [ ] 메모리 사용량 < 80%
- [ ] CPU 사용률 < 70% (idle)
- [ ] 10명 동시 접속 처리 가능

---

**계획 작성 완료일**: 2026-01-12
**검토 및 승인**: 필요 시 팀 리뷰
**다음 액션**: Phase 0 사전 준비 시작
