# Flutter iOS/Android CI/CD 배포 계획

**Date**: 2026-01-12
**Project**: Gear Freak Flutter App
**Research Document**: `thoughts/shared/research/flutter_cicd_deployment_research_2026-01-12.md`

---

## 개요

GitHub Actions와 Fastlane을 사용하여 iOS/Android 앱을 자동으로 빌드하고 배포하는 CI/CD 파이프라인을 구축합니다.

### 목표

1. **PR Checks**: 코드 분석, 테스트, 빌드 검증
2. **iOS 배포**: TestFlight → App Store
3. **Android 배포**: Play Store Internal → Beta → Production
4. **(Optional) Firebase App Distribution**: 빠른 베타 테스트

---

## Phase 1: 사전 준비 (Prerequisites)

### 목표
빌드 서명 및 배포에 필요한 키, 인증서, 서비스 계정을 생성합니다.

### 작업 목록

- [ ] **1.1 Android Keystore 생성**
  ```bash
  keytool -genkey -v -keystore keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias gear_freak_release
  ```
  - 생성된 keystore는 안전한 곳에 보관
  - 비밀번호 기록 필수

- [ ] **1.2 Android key.properties 설정**
  - `android/key.properties` 파일 생성 (gitignore에 추가)
  - `android/app/build.gradle`에 signing config 추가

- [ ] **1.3 iOS Match 저장소 생성**
  - Private GitHub repository 생성 (예: `pyowonsik/certificates`)
  - Personal Access Token (PAT) 생성 (repo 권한)

- [ ] **1.4 App Store Connect API Key 생성**
  - App Store Connect → Users and Access → Keys
  - "Admin" 또는 "App Manager" 역할 선택
  - .p8 파일 다운로드 (한 번만 가능!)

- [ ] **1.5 Google Play Service Account 생성**
  - Google Cloud Console에서 Service Account 생성
  - Play Console에서 API Access 연결
  - JSON 키 다운로드

- [ ] **1.6 GitHub Secrets 설정**

  | Secret Name | 설명 |
  |-------------|------|
  | `ENV_FILE` | Base64 인코딩된 .env 파일 |
  | `MATCH_PASSWORD` | Match 암호화 비밀번호 |
  | `MATCH_GIT_BASIC_AUTH` | `username:PAT` Base64 인코딩 |
  | `APP_STORE_CONNECT_KEY_ID` | API Key ID |
  | `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID |
  | `APP_STORE_CONNECT_PRIVATE_KEY` | .p8 파일 내용 |
  | `ANDROID_KEYSTORE_BASE64` | keystore.jks Base64 인코딩 |
  | `ANDROID_KEYSTORE_PASSWORD` | Keystore 비밀번호 |
  | `ANDROID_KEY_PASSWORD` | Key 비밀번호 |
  | `ANDROID_KEY_ALIAS` | Key 별칭 |
  | `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Service Account JSON |

### 검증 방법
- [ ] Keystore로 로컬에서 release APK 빌드 성공
- [ ] App Store Connect API Key로 인증 테스트
- [ ] Play Store Service Account로 인증 테스트

---

## Phase 2: Fastlane 설정

### 목표
iOS와 Android 각각에 Fastlane을 설정하고 로컬에서 테스트합니다.

### 작업 목록

- [ ] **2.1 Gemfile 생성**
  - `gear_freak_flutter/Gemfile` 생성
  - fastlane, cocoapods gem 추가

- [ ] **2.2 iOS Fastlane 초기화**
  ```bash
  cd gear_freak_flutter/ios
  fastlane init
  ```
  - Appfile 설정 (app_identifier, team_id 등)
  - Matchfile 설정 (certificates repository)

- [ ] **2.3 iOS Match 초기화**
  ```bash
  fastlane match init
  fastlane match development
  fastlane match appstore
  ```

- [ ] **2.4 iOS Fastfile 작성**
  - `beta` lane: TestFlight 배포
  - `release` lane: App Store 배포
  - `certificates` lane: 인증서 동기화

- [ ] **2.5 Android Fastlane 초기화**
  ```bash
  cd gear_freak_flutter/android
  fastlane init
  ```
  - Appfile 설정 (package_name, json_key_file)

- [ ] **2.6 Android Fastfile 작성**
  - `internal` lane: Internal Track 배포
  - `beta` lane: Beta Track 배포
  - `production` lane: Production 배포
  - `promote_to_beta` lane: Internal → Beta 승격

### 검증 방법
- [ ] `bundle exec fastlane ios beta` 로컬 테스트 (dry-run)
- [ ] `bundle exec fastlane android internal` 로컬 테스트 (dry-run)

---

## Phase 3: GitHub Actions 워크플로우

### 목표
PR Checks, iOS 배포, Android 배포 워크플로우를 생성합니다.

### 작업 목록

- [ ] **3.1 PR Checks 워크플로우**
  - `.github/workflows/flutter-pr-checks.yml`
  - 분석, 포맷팅 검사, 테스트 실행
  - Debug APK/iOS 빌드 (서명 없이)
  - Artifact 업로드

- [ ] **3.2 iOS TestFlight 배포 워크플로우**
  - `.github/workflows/deploy-ios-testflight.yml`
  - main 브랜치 push 시 또는 수동 실행
  - Flutter 빌드 → Fastlane 배포

- [ ] **3.3 Android Play Store 배포 워크플로우**
  - `.github/workflows/deploy-android-playstore.yml`
  - Track 선택 가능 (internal/alpha/beta/production)
  - Flutter 빌드 → Fastlane 배포

- [ ] **3.4 (Optional) Firebase App Distribution 워크플로우**
  - `.github/workflows/deploy-firebase-distribution.yml`
  - 빠른 베타 테스트용

### 검증 방법
- [ ] PR 생성 시 PR Checks 워크플로우 실행 확인
- [ ] feature 브랜치에서 배포 워크플로우 테스트
- [ ] main 브랜치 머지 후 자동 배포 확인

---

## Phase 4: 통합 테스트 및 문서화

### 목표
전체 파이프라인을 테스트하고 팀 문서를 작성합니다.

### 작업 목록

- [ ] **4.1 End-to-End 테스트**
  - PR 생성 → Checks 통과 → 머지 → 자동 배포
  - TestFlight에서 앱 설치 확인
  - Play Store Internal에서 앱 설치 확인

- [ ] **4.2 Branch Protection 설정**
  - main 브랜치에 PR 필수
  - Status checks 통과 필수

- [ ] **4.3 배포 문서 작성**
  - 배포 프로세스 가이드
  - 시크릿 로테이션 방법
  - 트러블슈팅 가이드

### 검증 방법
- [ ] 새 팀원이 문서만 보고 배포 프로세스 이해 가능
- [ ] 전체 배포 파이프라인 3회 이상 성공적 실행

---

## 파일 구조

```
gear_freak_flutter/
├── Gemfile                           # Ruby 의존성
├── Gemfile.lock
├── ios/
│   └── fastlane/
│       ├── Appfile                   # iOS 앱 설정
│       ├── Fastfile                  # iOS 배포 레인
│       └── Matchfile                 # 인증서 관리
├── android/
│   ├── key.properties                # 서명 설정 (gitignore)
│   ├── keystore.jks                  # 릴리스 키스토어 (gitignore)
│   └── fastlane/
│       ├── Appfile                   # Android 앱 설정
│       └── Fastfile                  # Android 배포 레인
└── .github/
    └── workflows/
        ├── flutter-pr-checks.yml     # PR 검사
        ├── deploy-ios-testflight.yml # iOS 배포
        └── deploy-android-playstore.yml # Android 배포
```

---

## 예상 소요 시간

| Phase | 예상 시간 |
|-------|----------|
| Phase 1: 사전 준비 | 2-3시간 |
| Phase 2: Fastlane 설정 | 3-4시간 |
| Phase 3: GitHub Actions | 2-3시간 |
| Phase 4: 통합 테스트 | 2-3시간 |

**총 예상 시간**: 9-13시간 (초기 설정, 이후 자동화)

---

## 주의사항

1. **인증서/키 보관**: Keystore, .p8 파일 등은 절대 Git에 커밋하지 않음
2. **시크릿 로테이션**: 주기적으로 API 키, 비밀번호 갱신
3. **빌드 번호 관리**: Fastlane이 자동으로 증가시킴
4. **앱 버전 관리**: pubspec.yaml의 version을 수동으로 관리

---

## 참고 문서

- [연구 문서](./thoughts/shared/research/flutter_cicd_deployment_research_2026-01-12.md)
- [Flutter CI/CD 공식 문서](https://docs.flutter.dev/deployment/cd)
- [Fastlane 문서](https://docs.fastlane.tools/)
- [GitHub Actions 문서](https://docs.github.com/en/actions)
