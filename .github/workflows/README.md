# GitHub Actions iOS CI/CD 가이드

## 📋 개요

Gear Freak Flutter 앱의 iOS 자동 배포를 위한 GitHub Actions 워크플로우입니다.

## 🔧 설정 완료 항목

- ✅ Fastlane 설정 (beta, release 레인)
- ✅ App Store Connect API Key 연동
- ✅ GitHub Actions Workflows 생성

## 📦 Workflow 종류

### 1. `ios-testflight.yml` - TestFlight 베타 배포
**용도**: 테스터에게 베타 버전 배포

**실행 시점**:
- 수동 실행 (기본)
- (선택) main 브랜치 push 시 자동 실행
- (선택) Tag 생성 시 자동 실행 (예: v1.0.0)

**수행 작업**:
1. Flutter 빌드 환경 설정
2. 의존성 설치 및 코드 분석
3. iOS 앱 빌드 (빌드 번호 자동 증가)
4. TestFlight 업로드

### 2. `ios-release.yml` - App Store 정식 배포
**용도**: App Store 심사 제출용 빌드 업로드

**실행 시점**:
- 수동 실행만 허용 (실수 방지)

**수행 작업**:
1. Flutter 빌드 환경 설정
2. iOS 앱 빌드 (빌드 번호 자동 증가)
3. App Store Connect 업로드
4. ⚠️ 심사 제출은 수동으로 진행 필요

### 3. `ios-build-check.yml` - 빌드 검증
**용도**: PR/push 시 빌드 성공 여부 확인

**실행 시점**:
- Pull Request 생성/업데이트
- develop 브랜치 push
- 수동 실행

**수행 작업**:
1. Flutter 코드 분석 (lint)
2. iOS 빌드 테스트 (업로드 없음)

## 🔐 필수 GitHub Secrets 설정

**설정 위치**: `저장소 → Settings → Secrets and variables → Actions`

| Secret 이름 | 값 | 설명 |
|------------|-----|------|
| `APP_STORE_CONNECT_API_KEY_ID` | `Y28LL7R646` | App Store Connect API Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | `fe34bf88-2267-4565-a7df-0208753cb935` | Issuer ID |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | AuthKey.p8 파일 내용 | API 키 전체 내용 (-----BEGIN PRIVATE KEY----- 포함) |

### AuthKey.p8 파일 내용 복사 방법:

```bash
# 로컬에서 파일 내용 출력
cat gear_freak_flutter/ios/fastlane/AuthKey.p8

# 출력된 전체 내용 복사 (예시)
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgQfn4E9hCzgcv/1Iv
...
-----END PRIVATE KEY-----
```

이 내용을 `APP_STORE_CONNECT_API_KEY_CONTENT` Secret에 붙여넣기하세요.

## 🚀 사용 방법

### TestFlight 배포하기

**1) GitHub Actions 탭 이동**
```
https://github.com/본인계정/gear_freak/actions
```

**2) "iOS TestFlight 배포" Workflow 선택**

**3) "Run workflow" 버튼 클릭**
- Branch 선택 (기본: main)
- "Run workflow" 확인

**4) 진행 상황 모니터링**
- 실시간 로그 확인 가능
- 약 10-20분 소요

**5) 배포 완료 후**
- App Store Connect에서 TestFlight 확인
- 테스터에게 알림 자동 발송

### App Store 정식 배포하기

**1) GitHub Actions 탭에서 "iOS App Store 정식 배포" 선택**

**2) "Run workflow" 실행**

**3) 완료 후 App Store Connect에서 수동 심사 제출**
```
https://appstoreconnect.apple.com
→ 앱 선택
→ 버전 선택
→ "심사 제출" 클릭
```

## 🔍 트러블슈팅

### 1. AuthKey.p8 파일 오류
```
Error: Could not find AuthKey.p8
```
**해결**: GitHub Secrets에 `APP_STORE_CONNECT_API_KEY_CONTENT`가 올바르게 설정되었는지 확인

### 2. 빌드 번호 중복 오류
```
Error: Build number already exists
```
**해결**: Fastlane이 자동으로 빌드 번호를 증가시킴. 로컬에서 수동으로 빌드 번호를 올린 경우 충돌 가능
```bash
# 로컬에서 빌드 번호 확인
cd gear_freak_flutter/ios
bundle exec fastlane bump_build
```

### 3. Flutter 버전 불일치
```
Error: Flutter version mismatch
```
**해결**: Workflow 파일의 `flutter-version`을 프로젝트 버전과 일치시키기
```yaml
# .github/workflows/ios-testflight.yml
- name: Flutter 설치
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'  # 프로젝트 버전에 맞게 수정
```

### 4. 인증서/프로비저닝 프로파일 오류
```
Error: No matching provisioning profiles found
```
**해결**:
- Xcode에서 자동 서명 확인
- 또는 fastlane match 사용 (고급)

### 5. Workflow 실행 로그 확인
- Actions 탭 → 실패한 Workflow 클릭
- 각 Step의 로그 확인
- "Artifacts" 섹션에서 빌드 로그 다운로드

## 📝 자동 실행 설정 (선택사항)

### Tag 생성 시 자동 배포

`ios-testflight.yml` 파일 수정:
```yaml
on:
  workflow_dispatch:  # 수동 실행 유지
  push:
    tags:
      - 'v*'  # v1.0.0, v1.0.1 등의 태그 생성 시 자동 실행
```

**사용 예시**:
```bash
# 로컬에서 태그 생성 및 푸시
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions가 자동으로 TestFlight 배포 시작
```

### main 브랜치 push 시 자동 배포

```yaml
on:
  workflow_dispatch:
  push:
    branches:
      - main  # main 브랜치에 push하면 자동 실행
```

⚠️ **주의**: 자동 실행은 실수로 배포될 수 있으니 신중히 설정하세요.

## 📊 배포 상태 뱃지 추가 (선택사항)

README.md에 배포 상태 표시:

```markdown
![iOS TestFlight](https://github.com/본인계정/gear_freak/actions/workflows/ios-testflight.yml/badge.svg)
```

## 🔗 참고 링크

- [Fastlane 공식 문서](https://docs.fastlane.tools/)
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Flutter 공식 문서](https://docs.flutter.dev/deployment/ios)

## 📞 지원

문제 발생 시:
1. Actions 탭에서 로그 확인
2. Artifacts에서 상세 로그 다운로드
3. Fastlane 로컬 테스트: `cd ios && bundle exec fastlane beta`
