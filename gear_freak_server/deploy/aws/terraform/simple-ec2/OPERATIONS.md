# Gear Freak Production 운영 체크리스트

**목적**: Gear Freak 프로덕션 서버의 안정적인 운영을 위한 정기 점검 가이드

**대상 환경**: AWS EC2 (3.36.158.97)

---

## 목차

1. [일일 체크](#일일-체크)
2. [주간 체크](#주간-체크)
3. [월간 체크](#월간-체크)
4. [백업 확인](#백업-확인)
5. [보안 업데이트](#보안-업데이트)
6. [모니터링 검토](#모니터링-검토)
7. [긴급 상황 대응](#긴급-상황-대응)

---

## 일일 체크

**소요 시간**: 5-10분
**담당자**: 운영팀
**시간**: 매일 오전 9시

### 1. 서비스 상태 확인

```bash
# API Health Check
curl -s https://api.gear-freaks.com | head -c 50

# 예상 응답: "OK [timestamp]"
```

**체크리스트**:
- [ ] API 응답 200 OK
- [ ] Insights 대시보드 접속 가능 (https://insights.gear-freaks.com)
- [ ] Web 서버 응답 확인 (https://app.gear-freaks.com)

### 2. 컨테이너 상태 확인

```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

cd /opt/gear_freak
docker-compose ps
```

**체크리스트**:
- [ ] gear_freak_serverpod: Up (healthy)
- [ ] gear_freak_postgres: Up (healthy)
- [ ] gear_freak_redis: Up (healthy)

**이상 증상**:
- `Restarting`: 컨테이너가 반복적으로 재시작 → 로그 확인 필요
- `Exited`: 컨테이너 중지됨 → `docker-compose up -d` 실행

### 3. 로그 에러 확인

```bash
# 최근 30분간 에러 로그 확인
docker-compose logs --since 30m serverpod 2>&1 | grep -i error | tail -20

# Critical/Fatal 에러 확인
docker-compose logs --since 30m serverpod 2>&1 | grep -iE "(critical|fatal)"
```

**체크리스트**:
- [ ] Critical/Fatal 에러 없음
- [ ] 반복적인 에러 패턴 없음
- [ ] DB 연결 에러 없음

**에러 발견 시**:
- 에러 메시지 복사하여 이슈 트래커에 기록
- 긴급도 판단 (High/Medium/Low)
- 필요 시 재시작 또는 롤백

### 4. 리소스 사용량 확인

```bash
# 컨테이너 리소스 사용량
docker stats --no-stream

# 디스크 사용량
df -h

# 메모리 사용량
free -h
```

**임계값**:
- [ ] CPU 사용률 < 80%
- [ ] 메모리 사용률 < 85% (t3.micro 850MB/1GB)
- [ ] 디스크 사용률 < 80% (16GB/20GB)

**초과 시 조치**:
- CPU 80% 이상: 로그 분석, 비정상 트래픽 확인
- 메모리 85% 이상: 컨테이너 재시작, t3.small 업그레이드 검토
- 디스크 80% 이상: 로그 정리, 오래된 백업 삭제

---

## 주간 체크

**소요 시간**: 20-30분
**담당자**: 운영팀 + DevOps
**시간**: 매주 월요일 오전 10시

### 1. 백업 상태 확인

```bash
# 로컬 백업 파일 확인 (최근 7일)
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
ls -lht /opt/gear_freak/backups/ | head -8

# S3 백업 확인
aws s3 ls s3://gear-freak-private-storage-3059875/backups/ --recursive | tail -10
```

**체크리스트**:
- [ ] 매일 백업 파일 생성 확인 (7개 파일)
- [ ] 백업 파일 크기 정상 (0 바이트 아님)
- [ ] S3 업로드 성공 확인
- [ ] 7일 이상 오래된 로컬 백업 자동 삭제 확인

**백업 복원 테스트** (월 1회):
```bash
# 테스트 DB 생성
docker exec gear_freak_postgres createdb -U postgres gear_freak_test

# 백업 복원
gunzip -c /opt/gear_freak/backups/postgres_20260113_030000.sql.gz | \
  docker exec -i gear_freak_postgres psql -U postgres -d gear_freak_test

# 데이터 확인
docker exec gear_freak_postgres psql -U postgres -d gear_freak_test -c "SELECT COUNT(*) FROM \"user\";"

# 테스트 DB 삭제
docker exec gear_freak_postgres dropdb -U postgres gear_freak_test
```

### 2. SSL 인증서 만료일 확인

```bash
sudo certbot certificates
```

**체크리스트**:
- [ ] 인증서 만료까지 30일 이상 남음
- [ ] 자동 갱신 타이머 활성화 (`systemctl status certbot-renew.timer`)

**만료 30일 이내**:
```bash
# 수동 갱신 테스트
sudo certbot renew --dry-run

# 실제 갱신
sudo certbot renew --force-renewal
sudo systemctl reload nginx
```

### 3. 로그 분석

```bash
# 일주일간 에러 통계
docker-compose logs --since 7d serverpod 2>&1 | grep -i error | wc -l

# 가장 빈번한 에러 패턴
docker-compose logs --since 7d serverpod 2>&1 | grep -i error | \
  awk '{print $5, $6, $7}' | sort | uniq -c | sort -nr | head -10

# Nginx 접속 통계
sudo cat /var/log/nginx/api.gear-freaks.com.access.log | \
  awk '{print $1}' | sort | uniq -c | sort -nr | head -20
```

**체크리스트**:
- [ ] 에러 발생 빈도 증가 추세 없음
- [ ] 비정상적인 IP 접속 패턴 없음
- [ ] 429 (Rate Limit) 응답 비율 < 1%

### 4. DB 성능 확인

```bash
# DB 크기 확인
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c "
SELECT
  pg_size_pretty(pg_database_size('gear_freak')) AS db_size;
"

# 테이블별 크기
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c "
SELECT
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname='public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;
"

# 슬로우 쿼리 확인 (설정된 경우)
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c "
SELECT
  calls,
  total_exec_time,
  mean_exec_time,
  query
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 5;
"
```

**체크리스트**:
- [ ] DB 크기 증가 추세 정상
- [ ] 특정 테이블 비정상 증가 없음
- [ ] 평균 쿼리 시간 < 100ms

### 5. 보안 로그 확인

```bash
# SSH 로그인 시도 확인
sudo journalctl -u sshd --since "7 days ago" | grep -i "failed\|invalid" | tail -20

# Fail2ban 상태 (설치된 경우)
sudo fail2ban-client status sshd

# 방화벽 규칙 확인
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw security_group_id) \
  --region ap-northeast-2
```

**체크리스트**:
- [ ] 무차별 대입 공격 시도 없음
- [ ] 비인가 IP로부터의 접근 시도 없음
- [ ] Security Group 규칙 변경 없음

---

## 월간 체크

**소요 시간**: 1-2시간
**담당자**: DevOps + 인프라팀
**시간**: 매월 1일

### 1. 시스템 업데이트

```bash
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97

# 업데이트 가능한 패키지 확인
sudo yum check-update

# 업데이트 실행 (사전 백업 필수)
sudo yum update -y

# 재부팅 필요 여부 확인
sudo needs-restarting -r

# 재부팅 (필요 시)
sudo reboot
```

**체크리스트**:
- [ ] 시스템 업데이트 완료
- [ ] 재부팅 후 모든 서비스 자동 시작 확인
- [ ] API Health Check 통과

### 2. Docker 이미지 정리

```bash
# 미사용 이미지 확인
docker images -f "dangling=true"

# 미사용 이미지 삭제
docker image prune -a -f

# 디스크 공간 확보
docker system prune -a -f
```

**체크리스트**:
- [ ] 미사용 이미지 삭제
- [ ] 디스크 공간 10GB 이상 확보

### 3. 로그 정리 및 아카이브

```bash
# 30일 이상 오래된 Nginx 로그 압축
sudo find /var/log/nginx -name "*.log" -mtime +30 -exec gzip {} \;

# 90일 이상 오래된 압축 로그 삭제
sudo find /var/log/nginx -name "*.gz" -mtime +90 -delete

# Docker 로그 크기 확인
docker inspect --format='{{.LogPath}}' gear_freak_serverpod | xargs sudo du -h
```

**체크리스트**:
- [ ] 오래된 로그 압축/삭제
- [ ] Docker 로그 크기 < 500MB

### 4. 성능 벤치마크

```bash
# API 응답 시간 측정 (10회 평균)
for i in {1..10}; do
  curl -o /dev/null -s -w "Time: %{time_total}s\n" https://api.gear-freaks.com
done

# DB 쿼리 성능 테스트
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c "
EXPLAIN ANALYZE SELECT * FROM product ORDER BY created_at DESC LIMIT 20;
"
```

**체크리스트**:
- [ ] API 평균 응답 시간 < 500ms
- [ ] DB 쿼리 실행 시간 < 100ms
- [ ] 이전 달 대비 성능 저하 없음

### 5. 비용 분석

```bash
# AWS Cost Explorer 확인 (Web Console)
# 또는 CLI로 확인
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "1 month ago" +%Y-%m-01),End=$(date +%Y-%m-01) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

**체크리스트**:
- [ ] 월간 비용 예산 내 ($15 이하)
- [ ] 비정상적인 비용 증가 없음
- [ ] Free Tier 사용량 확인

### 6. 재해 복구 훈련 (분기 1회)

**시나리오**: EC2 인스턴스 장애 시 복구

```bash
# 1. Terraform으로 새 인스턴스 생성 (동일 설정)
terraform apply

# 2. 최신 백업 복원
# (S3에서 다운로드 → PostgreSQL 복원)

# 3. DNS 전환 (Elastic IP 재할당)

# 4. 서비스 정상화 확인

# 5. 소요 시간 기록
```

**목표 복구 시간**: RTO < 1시간

---

## 백업 확인

### 자동 백업 설정

**백업 스크립트**: `/opt/gear_freak/backup.sh`

```bash
# Cron 작업 확인
crontab -l | grep backup

# 예상 출력:
# 0 3 * * * /opt/gear_freak/backup.sh >> /var/log/backup.log 2>&1
```

### 백업 정책

| 항목 | 설정 |
|------|------|
| 백업 주기 | 매일 새벽 3시 |
| 보관 기간 (로컬) | 7일 |
| 보관 기간 (S3) | 30일 |
| 백업 대상 | PostgreSQL (gear_freak DB) |
| 백업 형식 | SQL dump (gzip 압축) |

### 수동 백업

```bash
# 긴급 백업 (배포 전)
ssh -i ~/.ssh/gear-freak-server-key.pem ec2-user@3.36.158.97
/opt/gear_freak/backup.sh

# 백업 확인
ls -lh /opt/gear_freak/backups/
```

### 백업 복원 절차

```bash
# 1. 백업 파일 확인
ls -lh /opt/gear_freak/backups/

# 2. 현재 DB 백업 (혹시 모를 롤백용)
/opt/gear_freak/backup.sh

# 3. 복원할 백업 선택
BACKUP_FILE="postgres_20260113_030000.sql.gz"

# 4. DB 복원
gunzip -c /opt/gear_freak/backups/$BACKUP_FILE | \
  docker exec -i gear_freak_postgres psql -U postgres -d gear_freak

# 5. Serverpod 재시작
cd /opt/gear_freak
docker-compose restart serverpod

# 6. 데이터 확인
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c "SELECT COUNT(*) FROM \"user\";"
```

---

## 보안 업데이트

### 정기 보안 점검

**주기**: 매주 월요일

```bash
# 1. 시스템 보안 업데이트 확인
sudo yum check-update --security

# 2. Docker 이미지 취약점 스캔 (Trivy 사용)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image pyowonsik/gear-freak-server:latest

# 3. Nginx 버전 확인
nginx -v

# 4. OpenSSL 버전 확인
openssl version
```

### 보안 권장 사항

**SSH 보안**:
- [ ] SSH 포트 변경 검토 (기본 22 → 2222 등)
- [ ] 비밀번호 인증 비활성화 (키 기반만)
- [ ] fail2ban 설치 및 활성화

**방화벽**:
- [ ] Security Group에서 불필요한 포트 차단
- [ ] admin_ip를 최신 IP로 업데이트

**SSL/TLS**:
- [ ] SSL Labs 테스트 Grade A 이상 유지
- [ ] TLS 1.2 이상만 허용
- [ ] 강력한 암호화 스위트 사용

**애플리케이션**:
- [ ] 환경변수 파일 권한 600 유지
- [ ] 민감 정보 로그에 노출 방지
- [ ] API Rate Limiting 설정

---

## 모니터링 검토

### 핵심 메트릭

**서비스 가용성**:
- [ ] Uptime > 99.9%
- [ ] 평균 응답 시간 < 500ms
- [ ] 에러율 < 0.1%

**리소스 사용률**:
- [ ] CPU 평균 < 50%, 최대 < 80%
- [ ] 메모리 평균 < 70%, 최대 < 85%
- [ ] 디스크 사용률 < 80%

**트래픽**:
- [ ] 일일 API 요청 수 추이
- [ ] 동시 접속자 수 최대값
- [ ] 데이터 전송량 (Inbound/Outbound)

### CloudWatch 알람 설정 (권장)

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
  --dimensions Name=InstanceId,Value=$(terraform output -raw instance_id)

# 메모리 부족 알람 (CloudWatch Agent 필요)
# 디스크 사용률 80% 이상 알람
# API 5xx 에러 알람
```

---

## 긴급 상황 대응

### 서비스 다운 (Critical)

**증상**: API 응답 없음, Insights 접속 불가

**즉시 조치**:
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

# 5. EC2 재부팅 (최후의 수단)
sudo reboot
```

### DB 연결 실패 (High)

**증상**: `Failed to connect to database`

**조치**:
```bash
# 1. PostgreSQL 상태 확인
docker-compose ps postgres

# 2. PostgreSQL 로그 확인
docker-compose logs postgres --tail 50

# 3. PostgreSQL 재시작
docker-compose restart postgres

# 4. 연결 테스트
docker exec gear_freak_postgres psql -U postgres -d gear_freak -c "SELECT version();"
```

### 디스크 풀 (High)

**증상**: `No space left on device`

**조치**:
```bash
# 1. 디스크 사용량 확인
df -h

# 2. 큰 파일 찾기
sudo du -h /opt/gear_freak | sort -rh | head -20

# 3. 오래된 백업 삭제
find /opt/gear_freak/backups -name "*.sql.gz" -mtime +7 -delete

# 4. Docker 정리
docker system prune -a -f

# 5. 로그 정리
sudo journalctl --vacuum-time=7d
```

### SSL 인증서 만료 (High)

**증상**: `NET::ERR_CERT_DATE_INVALID`

**조치**:
```bash
# 즉시 갱신
sudo certbot renew --force-renewal
sudo systemctl reload nginx

# 만료일 확인
sudo certbot certificates
```

---

## 체크리스트 템플릿

### 일일 체크 (Daily)

```
날짜: 2026-01-__
담당자: ______

[ ] API 응답 정상
[ ] 모든 컨테이너 실행 중
[ ] 에러 로그 없음
[ ] 리소스 사용률 정상

메모:
```

### 주간 체크 (Weekly)

```
주차: 2026년 __주차 (MM/DD ~ MM/DD)
담당자: ______

[ ] 백업 7개 확인
[ ] SSL 만료일 30일 이상
[ ] 로그 분석 완료
[ ] DB 성능 정상
[ ] 보안 로그 이상 없음

발견 이슈:

조치 사항:
```

### 월간 체크 (Monthly)

```
월: 2026년 __월
담당자: ______

[ ] 시스템 업데이트 완료
[ ] Docker 정리 완료
[ ] 로그 아카이브 완료
[ ] 성능 벤치마크 정상
[ ] 비용 예산 내
[ ] 재해 복구 훈련 (분기)

개선 사항:

다음 달 계획:
```

---

**작성자**: Claude Code
**마지막 업데이트**: 2026-01-13
**다음 검토**: 2026-02-01
