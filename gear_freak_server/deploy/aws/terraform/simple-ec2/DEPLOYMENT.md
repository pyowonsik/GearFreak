# Gear Freak Production 배포 가이드

**작성일**: 2026-01-13
**대상 환경**: AWS EC2 (3.36.158.97)
**Docker Hub**: pyowonsik/gear-freak-server

---

## 목차

1. [배포 시나리오별 프로세스](#배포-시나리오별-프로세스)
2. [빠른 배포 스크립트](#빠른-배포-스크립트)
3. [자동화 (CI/CD)](#자동화-cicd)
4. [트러블슈팅](#트러블슈팅)
5. [유용한 명령어 모음](#유용한-명령어-모음)

---

## 배포 시나리오별 프로세스

### 시나리오 1: DB 스키마 변경 (마이그레이션)

엔드포인트나 비즈니스 로직은 변경 없고, **DB 스키마만 변경**된 경우

#### 로컬 작업

```bash
cd gear_freak_server

# 1. Protocol 파일 수정 (예: product.spy)
# lib/src/protocol/product.dart 등 수정

# 2. Serverpod Generate
serverpod generate

# 3. 새 마이그레이션 생성
serverpod create-migration

# 마이그레이션 폴더 확인 (예: migrations/20260113120000/)
ls -l migrations/
```

#### EC2 배포

```bash
# 1. 최신 마이그레이션 폴더 확인
MIGRATION_DIR=$(ls -1d migrations/*/ | sort -r | head -1)
echo "최신 마이그레이션: $MIGRATION_DIR"

# 2. definition.sql을 EC2로 복사
scp -i ~/.ssh/gear-freak-server-key.pem \
    ${MIGRATION_DIR}definition.sql \
    ec2-user@3.36.158.97:/tmp/migration.sql

# 3. PostgreSQL에 마이그레이션 실행
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97 << 'EOF'
docker exec -i gear_freak_postgres psql -U postgres -d gear_freak < /tmp/migration.sql
echo "✅ 마이그레이션 완료"
EOF
```

**주의사항**:
- `definition.sql`은 전체 스키마 정의 (DROP CASCADE 포함)
- `migration.sql`은 증분 마이그레이션 (테이블 변경만)
- 운영 환경에서는 **migration.sql 사용 권장** (데이터 유지)

---

### 시나리오 2: 엔드포인트/코드 변경

DB 스키마는 그대로, **엔드포인트 추가/수정 또는 비즈니스 로직 변경**된 경우

#### 로컬 작업

```bash
cd gear_freak_server

# 1. 코드 수정 후 테스트
# (lib/src/endpoints/*.dart 등 수정)

# 2. Docker 이미지 빌드
docker build -t pyowonsik/gear-freak-server:latest .

# 3. 이미지 크기 확인 (선택사항)
docker images pyowonsik/gear-freak-server:latest

# 4. Docker Hub에 푸시
docker push pyowonsik/gear-freak-server:latest
```

**빌드 시간**: 약 2-5분 (네트워크 속도에 따라)

#### EC2 배포

```bash
# SSH 접속
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

# /opt/gear_freak 디렉토리로 이동
cd /opt/gear_freak

# 1. 최신 이미지 다운로드
docker-compose pull serverpod

# 2. Serverpod 컨테이너 재시작 (무중단)
docker-compose up -d serverpod

# 3. 로그 확인 (5초 대기 후)
sleep 5
docker-compose logs --tail 30 serverpod

# 4. 서비스 상태 확인
docker-compose ps

# 5. Health Check
curl -s https://api.gear-freaks.com | head -c 100
```

**배포 시간**: 약 30초 ~ 1분

---

### 시나리오 3: DB + 코드 둘 다 변경

**DB 스키마와 엔드포인트 모두 변경**된 경우 (가장 흔한 케이스)

#### 전체 프로세스

```bash
# ===== 로컬 작업 =====
cd gear_freak_server

# 1. 코드 수정 및 마이그레이션 생성
serverpod generate
serverpod create-migration

# 2. Docker 이미지 빌드 & 푸시
docker build -t pyowonsik/gear-freak-server:latest .
docker push pyowonsik/gear-freak-server:latest

# 3. 마이그레이션 파일 복사
MIGRATION_DIR=$(ls -1d migrations/*/ | sort -r | head -1)
scp -i ~/.ssh/gear-freak-server-key.pem \
    ${MIGRATION_DIR}migration.sql \
    ec2-user@3.36.158.97:/tmp/migration.sql

# ===== EC2 배포 =====
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97 << 'EOF'
# 1. DB 마이그레이션
echo "Step 1: DB 마이그레이션 실행..."
docker exec -i gear_freak_postgres psql -U postgres -d gear_freak < /tmp/migration.sql

# 2. Serverpod 업데이트
echo "Step 2: Serverpod 이미지 업데이트..."
cd /opt/gear_freak
docker-compose pull serverpod
docker-compose up -d serverpod

# 3. 상태 확인
echo "Step 3: 배포 완료 확인..."
sleep 5
docker-compose ps
docker-compose logs --tail 20 serverpod

echo "✅ 배포 완료!"
EOF
```

---

### 시나리오 4: 환경변수 변경

FCM, S3, Redis 등 **환경변수만 변경**된 경우

#### EC2 작업

```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

cd /opt/gear_freak

# 1. .env 파일 수정
vi .env
# 또는 nano .env

# 2. 변경 내용 확인
cat .env | grep FCM

# 3. Serverpod만 재시작 (환경변수 재로드)
docker-compose up -d serverpod

# 4. 환경변수 적용 확인
docker exec gear_freak_serverpod env | grep FCM
```

---

### 시나리오 5: Nginx 설정 변경

리버스 프록시, 타임아웃 등 **Nginx 설정 변경**된 경우

#### EC2 작업

```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

# 1. Nginx 설정 파일 수정
sudo vi /etc/nginx/conf.d/serverpod.conf

# 2. 문법 검사
sudo nginx -t

# 3. Nginx 재시작
sudo systemctl reload nginx

# 4. 상태 확인
sudo systemctl status nginx
```

---

## 빠른 배포 스크립트

### 스크립트 생성

프로젝트 루트에 `deploy-production.sh` 생성:

```bash
#!/bin/bash
# Gear Freak Production Deployment Script
# Usage: ./deploy-production.sh [option]
# Options:
#   code    - 코드만 배포 (Docker 이미지)
#   db      - DB 마이그레이션만 실행
#   all     - 전체 배포 (기본값)

set -e

# 설정
SSH_KEY="$HOME/.ssh/gear-freak-server-key.pem"
EC2_HOST="ec2-user@3.36.158.97"
DOCKER_IMAGE="pyowonsik/gear-freak-server:latest"
SERVER_DIR="/opt/gear_freak"

# 색상 출력
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    log_warn "현재 브랜치: $CURRENT_BRANCH (main이 아님)"
    read -p "계속하시겠습니까? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 옵션 파싱
DEPLOY_TYPE=${1:-all}

case $DEPLOY_TYPE in
    code)
        log_info "코드 배포 시작..."

        # Docker 빌드
        log_info "[1/3] Docker 이미지 빌드 중..."
        docker build -t $DOCKER_IMAGE .

        # Docker 푸시
        log_info "[2/3] Docker Hub에 푸시 중..."
        docker push $DOCKER_IMAGE

        # EC2 배포
        log_info "[3/3] EC2에 배포 중..."
        ssh -i $SSH_KEY $EC2_HOST << 'EOF'
cd /opt/gear_freak
docker-compose pull serverpod
docker-compose up -d serverpod
sleep 5
docker-compose logs --tail 20 serverpod
EOF
        log_info "✅ 코드 배포 완료!"
        ;;

    db)
        log_info "DB 마이그레이션 시작..."

        # 최신 마이그레이션 찾기
        MIGRATION_DIR=$(ls -1d migrations/*/ | sort -r | head -1)
        if [ -z "$MIGRATION_DIR" ]; then
            log_error "마이그레이션 파일을 찾을 수 없습니다."
            exit 1
        fi

        log_info "마이그레이션: $MIGRATION_DIR"

        # migration.sql 복사
        if [ ! -f "${MIGRATION_DIR}migration.sql" ]; then
            log_error "migration.sql 파일이 없습니다. definition.sql을 사용하시겠습니까? (주의: 데이터 손실 가능)"
            read -p "definition.sql 사용? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                MIGRATION_FILE="definition.sql"
            else
                exit 1
            fi
        else
            MIGRATION_FILE="migration.sql"
        fi

        log_info "[1/2] 마이그레이션 파일 복사 중..."
        scp -i $SSH_KEY "${MIGRATION_DIR}${MIGRATION_FILE}" $EC2_HOST:/tmp/migration.sql

        log_info "[2/2] 마이그레이션 실행 중..."
        ssh -i $SSH_KEY $EC2_HOST << 'EOF'
docker exec -i gear_freak_postgres psql -U postgres -d gear_freak < /tmp/migration.sql
echo "✅ 마이그레이션 완료"
EOF
        ;;

    all)
        log_info "전체 배포 시작..."

        # 1. 마이그레이션
        log_info "===== Step 1: DB 마이그레이션 ====="
        $0 db

        # 2. 코드 배포
        log_info "===== Step 2: 코드 배포 ====="
        $0 code

        log_info "===== 전체 배포 완료! ====="

        # 최종 상태 확인
        log_info "서비스 상태 확인 중..."
        ssh -i $SSH_KEY $EC2_HOST << 'EOF'
cd /opt/gear_freak
docker-compose ps
echo ""
echo "최근 로그:"
docker-compose logs --tail 10 serverpod
EOF
        ;;

    *)
        log_error "알 수 없는 옵션: $DEPLOY_TYPE"
        echo "사용법: $0 [code|db|all]"
        exit 1
        ;;
esac

echo ""
log_info "배포 완료 시각: $(date '+%Y-%m-%d %H:%M:%S')"
```

### 스크립트 사용법

```bash
# 실행 권한 부여
chmod +x deploy-production.sh

# 전체 배포 (DB + 코드)
./deploy-production.sh all

# 코드만 배포
./deploy-production.sh code

# DB 마이그레이션만
./deploy-production.sh db
```

---

## 자동화 (CI/CD)

### GitHub Actions 설정

프로젝트 루트에 `.github/workflows/deploy-production.yml` 생성:

```yaml
name: Deploy to Production

on:
  push:
    branches:
      - main
  workflow_dispatch:  # 수동 실행 가능

jobs:
  deploy:
    name: Deploy to AWS EC2
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: pyowonsik
          password: ${{ secrets.DOCKER_HUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: pyowonsik/gear-freak-server:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Deploy to EC2
        uses: appleboy/ssh-action@master
        with:
          host: 3.36.158.97
          username: ec2-user
          key: ${{ secrets.EC2_SSH_PRIVATE_KEY }}
          script: |
            cd /opt/gear_freak
            docker-compose pull serverpod
            docker-compose up -d serverpod
            sleep 5
            docker-compose logs --tail 20 serverpod

      - name: Verify deployment
        run: |
          sleep 10
          curl -f https://api.gear-freaks.com || exit 1
          echo "✅ Deployment successful!"
```

### GitHub Secrets 설정

GitHub Repository → Settings → Secrets and variables → Actions → New repository secret

1. **DOCKER_HUB_TOKEN**
   - Docker Hub → Account Settings → Security → New Access Token
   - 토큰 생성 후 복사하여 입력

2. **EC2_SSH_PRIVATE_KEY**
   - `~/.ssh/gear-freak-server-key.pem` 파일 내용 전체 복사
   - BEGIN/END 포함하여 붙여넣기

### 자동화 워크플로우

1. **로컬 작업**:
   ```bash
   git add .
   git commit -m "feat: Add new endpoint"
   git push origin main
   ```

2. **GitHub Actions 자동 실행**:
   - Docker 이미지 빌드
   - Docker Hub 푸시
   - EC2 배포
   - Health check

3. **결과 확인**:
   - GitHub → Actions 탭에서 진행 상황 확인
   - 약 3-5분 후 배포 완료

---

## 트러블슈팅

### 문제 1: Docker 빌드 실패

**증상**:
```
ERROR: failed to solve: process "/bin/sh -c dart compile exe bin/main.dart" did not complete successfully
```

**해결**:
```bash
# 1. 로컬에서 빌드 테스트
cd gear_freak_server
dart pub get
dart compile exe bin/main.dart -o bin/server

# 2. Dockerfile의 단계별 확인
docker build --progress=plain -t test .

# 3. 캐시 삭제 후 재빌드
docker build --no-cache -t pyowonsik/gear-freak-server:latest .
```

---

### 문제 2: EC2에서 이미지 pull 실패

**증상**:
```
Error response from daemon: pull access denied for pyowonsik/gear-freak-server
```

**해결**:
```bash
# EC2에서 Docker Hub 로그인
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
docker login
# Username: pyowonsik
# Password: [Docker Hub Access Token]

# 재시도
cd /opt/gear_freak
docker-compose pull serverpod
```

---

### 문제 3: Serverpod 컨테이너 시작 실패

**증상**:
```
Container gear_freak_serverpod Exited (1)
```

**해결**:
```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

# 로그 확인
docker logs gear_freak_serverpod --tail 100

# 일반적인 원인:
# 1. DB 연결 실패 → production.yaml 확인
# 2. 환경변수 누락 → .env 파일 확인
# 3. 포트 충돌 → docker ps -a로 확인

# DB 연결 테스트
docker exec -it gear_freak_postgres psql -U postgres -d gear_freak -c "SELECT version();"

# 환경변수 확인
docker exec gear_freak_serverpod env | grep -E "(FCM|AWS|POSTGRES|REDIS)"
```

---

### 문제 4: 마이그레이션 실행 오류

**증상**:
```
ERROR: relation "product" already exists
```

**해결**:
```bash
# 옵션 1: migration.sql 사용 (증분 마이그레이션)
# 이미 존재하는 테이블은 ALTER만 실행

# 옵션 2: 특정 테이블만 DROP 후 재생성
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
docker exec -it gear_freak_postgres psql -U postgres -d gear_freak

DROP TABLE IF EXISTS product CASCADE;
# 이후 migration.sql 실행

# 옵션 3: 전체 초기화 (주의: 데이터 손실)
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
# definition.sql 실행
```

---

### 문제 5: SSL 인증서 만료

**증상**:
```
NET::ERR_CERT_DATE_INVALID
```

**해결**:
```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

# 인증서 갱신
sudo certbot renew --force-renewal

# Nginx 재시작
sudo systemctl reload nginx

# 만료일 확인
sudo certbot certificates
```

---

### 문제 6: FCM 푸시 알림 안 됨

**체크리스트**:
```bash
# 1. FCM 환경변수 확인
docker exec gear_freak_serverpod env | grep FCM
# FCM_PROJECT_ID=gear-freak
# FCM_SERVICE_ACCOUNT_PATH=./config/fcm-service-account.json

# 2. FCM 서비스 계정 파일 존재 확인
ls -la /opt/gear_freak/config/fcm-service-account.json

# 3. 파일 권한 확인
ls -l /opt/gear_freak/config/fcm-service-account.json
# -rw------- (600)

# 4. Serverpod 로그에서 FCM 에러 확인
docker logs gear_freak_serverpod --tail 100 | grep -i fcm
```

---

## 유용한 명령어 모음

### EC2 접속

```bash
# SSH 접속
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

# SSH 터널링 (로컬에서 DB 접속용)
ssh -i ~/.ssh/gear-freak-server-key.pem -L 5432:localhost:5432 ec2-user@3.36.158.97
```

### Docker 관리

```bash
# 모든 컨테이너 상태
docker-compose ps

# 특정 컨테이너 로그
docker-compose logs -f serverpod

# 컨테이너 재시작
docker-compose restart serverpod

# 컨테이너 중지 후 재시작
docker-compose down serverpod
docker-compose up -d serverpod

# 리소스 사용량 확인
docker stats

# 디스크 사용량 확인
docker system df

# 미사용 이미지 정리
docker image prune -a
```

### PostgreSQL 관리

```bash
# PostgreSQL 접속
docker exec -it gear_freak_postgres psql -U postgres -d gear_freak

# 테이블 목록
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c '\dt'

# 테이블 레코드 수 확인
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c "
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
    (SELECT COUNT(*) FROM user) AS user_count,
    (SELECT COUNT(*) FROM product) AS product_count
FROM pg_tables
WHERE schemaname='public'
LIMIT 5;"

# 백업 생성
docker exec gear_freak_postgres pg_dump -U postgres gear_freak > backup_$(date +%Y%m%d_%H%M%S).sql

# 백업 복원
docker exec -i gear_freak_postgres psql -U postgres -d gear_freak < backup_20260113_120000.sql
```

### Nginx 관리

```bash
# Nginx 설정 테스트
sudo nginx -t

# Nginx 재시작
sudo systemctl reload nginx

# Nginx 로그 확인
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# 특정 도메인 로그
sudo tail -f /var/log/nginx/api.gear-freaks.com.access.log
```

### 서비스 상태 확인

```bash
# API Health Check
curl https://api.gear-freaks.com

# Insights 접속 (브라우저)
open https://insights.gear-freaks.com

# 응답 시간 측정
time curl -o /dev/null -s -w "Time: %{time_total}s\n" https://api.gear-freaks.com

# SSL 인증서 확인
echo | openssl s_client -servername api.gear-freaks.com -connect api.gear-freaks.com:443 2>/dev/null | openssl x509 -noout -dates
```

### 시스템 리소스 모니터링

```bash
# CPU, 메모리 사용량
htop

# 디스크 사용량
df -h

# Docker 컨테이너 리소스
docker stats --no-stream

# 네트워크 연결 확인
netstat -tulpn | grep -E '(8080|8081|8082|5432|6379)'
```

### 로그 분석

```bash
# 에러 로그만 필터링
docker logs gear_freak_serverpod 2>&1 | grep -i error

# 특정 시간대 로그
docker logs gear_freak_serverpod --since "2026-01-13T12:00:00" --until "2026-01-13T13:00:00"

# 실시간 로그 (여러 컨테이너)
docker-compose logs -f --tail 50 serverpod postgres redis
```

---

## 배포 체크리스트

### 배포 전

- [ ] 로컬에서 테스트 완료
- [ ] Git commit & push 완료
- [ ] 마이그레이션 파일 생성 확인 (DB 변경 시)
- [ ] production.yaml 설정 확인
- [ ] 환경변수 변경사항 확인

### 배포 중

- [ ] Docker 이미지 빌드 성공
- [ ] Docker Hub 푸시 성공
- [ ] 마이그레이션 실행 성공 (DB 변경 시)
- [ ] Serverpod 컨테이너 재시작 성공
- [ ] 로그에 에러 없음

### 배포 후

- [ ] API Health Check (https://api.gear-freaks.com)
- [ ] Insights 접속 확인 (https://insights.gear-freaks.com)
- [ ] Flutter 앱 테스트
  - [ ] 로그인
  - [ ] 상품 조회/등록
  - [ ] 이미지 업로드
  - [ ] 채팅
  - [ ] FCM 푸시 알림
- [ ] 로그 모니터링 (10분간)
- [ ] 메모리/CPU 사용량 확인

---

## 긴급 상황 대응

### 서비스 다운

```bash
# 1. 빠른 상태 확인
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
cd /opt/gear_freak
docker-compose ps

# 2. 모든 컨테이너 재시작
docker-compose restart

# 3. 로그 확인
docker-compose logs --tail 100

# 4. 여전히 안 되면 전체 재시작
docker-compose down
docker-compose up -d
```

### 롤백

```bash
# 1. 이전 Docker 이미지로 롤백
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
cd /opt/gear_freak

# 2. docker-compose.yml 수정
vi docker-compose.yml
# image: pyowonsik/gear-freak-server:v1.0.0 (이전 버전 태그)

# 3. 재시작
docker-compose up -d serverpod

# 4. DB 롤백 (백업에서 복원)
# 사전에 백업해둔 SQL 파일 사용
docker exec -i gear_freak_postgres psql -U postgres -d gear_freak < backup.sql
```

---

## 참고 자료

- **Terraform 설정**: `main.tf`, `variables.tf`, `outputs.tf`
- **User Data 스크립트**: `user-data.sh`
- **Docker Compose**: `docker-compose.production.yml`
- **Nginx 설정**: `nginx.conf.template`
- **배포 계획**: `thoughts/shared/plans/aws_ec2_deployment_plan_2026-01-12.md`
- **검증 보고서**: `thoughts/shared/validate/aws_ec2_deployment_validation_2026-01-13.md`

---

**작성자**: Claude Code
**마지막 업데이트**: 2026-01-13
