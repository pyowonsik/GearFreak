# 문서 인덱스

gear_freak 프로젝트의 주요 문서 목록입니다.

## 📚 문서 목록

### 1. Serverpod 관련

#### `ENDPOINT_SETUP_GUIDE.md`

- Serverpod 엔드포인트 설정 가이드
- 인증 모듈 설정 방법
- 엔드포인트 생성 예시

#### `SERVERPOD_AUTH_STORAGE.md`

- Serverpod 인증 저장 방식 설명
- SharedPreferences vs FlutterSecureStorage
- SessionManager 동작 원리

#### `SERVERPOD_EMAIL_AUTH_COMPARISON.md`

- Serverpod 공식 이메일 인증 플로우
- 현재 프로젝트의 개발용 인증 방식
- 프로덕션 환경 권장사항

#### `SERVERPOD_SESSION_FLOW.md`

- Serverpod Session과 getCurrentUser 동작 흐름
- 클라이언트-서버 인증 흐름
- 데이터 일관성 설명

---

### 2. 인프라 관련

#### `S3_INFRASTRUCTURE_GUIDE.md`

- S3 버킷 Terraform 배포 가이드
- AWS CLI 설정
- IAM 사용자 생성
- 배포 확인 및 문제 해결

#### `UNIVERSAL_LINKS_GUIDE.md`

- Universal Links / App Links 구현 가이드
- Flutter 앱 설정
- 인프라 배포 (Route53 + CloudFront + S3)
- 인증 파일 업로드 및 테스트

---

### 3. Terraform 관련

#### `gear_freak_server/deploy/aws/terraform/TERRAFORM_FILES_STATUS.md`

- Terraform 파일 상태 정리
- 사용 중인 파일 vs 미사용 파일
- 현재 배포된 리소스 요약

---

## 📝 문서 정리 이력

### 삭제된 문서

- `KOBIC_AUTH_ANALYSIS.md` - 다른 프로젝트(kobic) 분석 문서
- `SERVERPOD_MIGRATION_GUIDE.md` - 마이그레이션 가이드 (현재 프로젝트는 이미 Serverpod 사용 중)
- `INFRASTRUCTURE_SETUP.md` - `S3_INFRASTRUCTURE_GUIDE.md`로 통합
- `S3_BUCKET_DEPLOYMENT_GUIDE.md` - `S3_INFRASTRUCTURE_GUIDE.md`로 통합
- `S3_SETUP_GUIDE.md` - `S3_INFRASTRUCTURE_GUIDE.md`로 통합
- `UNIVERSAL_LINKS_IMPLEMENTATION.md` - `UNIVERSAL_LINKS_GUIDE.md`로 통합
- `UNIVERSAL_LINKS_DEPLOYMENT.md` - `UNIVERSAL_LINKS_GUIDE.md`로 통합

### 통합된 문서

- **S3 관련**: 3개 문서 → `S3_INFRASTRUCTURE_GUIDE.md` 1개로 통합
- **Universal Links 관련**: 2개 문서 → `UNIVERSAL_LINKS_GUIDE.md` 1개로 통합

### 정리된 문서

- `SERVERPOD_EMAIL_AUTH_COMPARISON.md` - kobic 관련 내용 제거
- `ENDPOINT_SETUP_GUIDE.md` - 간소화

---

## 🎯 문서 사용 가이드

### 처음 시작하는 경우

1. `S3_INFRASTRUCTURE_GUIDE.md` - 인프라 설정
2. `ENDPOINT_SETUP_GUIDE.md` - Serverpod 엔드포인트 설정
3. `UNIVERSAL_LINKS_GUIDE.md` - 딥링크 구현

### 인증 관련 이해가 필요한 경우

1. `SERVERPOD_AUTH_STORAGE.md` - 인증 저장 방식
2. `SERVERPOD_SESSION_FLOW.md` - 세션 동작 흐름
3. `SERVERPOD_EMAIL_AUTH_COMPARISON.md` - 이메일 인증 방식

### 인프라 관리가 필요한 경우

1. `S3_INFRASTRUCTURE_GUIDE.md` - S3 설정
2. `TERRAFORM_FILES_STATUS.md` - Terraform 파일
3. `UNIVERSAL_LINKS_GUIDE.md` - Universal Links 인프라

---

**최종 업데이트**: 2025-11-26
