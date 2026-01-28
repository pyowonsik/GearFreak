# 트러블슈팅

## iOS CI/CD TestFlight 배포 구성

---

### 🚨 문제 배경

GitHub Actions + Fastlane을 사용하여 iOS 앱을 TestFlight에 자동 배포하는 CI/CD 파이프라인을 구성하면서 다양한 문제를 경험했습니다.

주요 이슈:
- 코드 서명(Code Signing) 설정
- 인증서 및 프로비저닝 프로파일 설치
- App Store Connect API 키 설정
- Entitlements 설정 충돌
- 버전/빌드 번호 관리

총 **20개 이상의 커밋**을 통해 문제를 해결했습니다.

---

### ⭐ 최종 구성

#### GitHub Actions Workflow 구조

```yaml
# .github/workflows/ios-testflight.yml

jobs:
  build:
    runs-on: macos-latest
    steps:
      # 1. 저장소 체크아웃
      # 2. Flutter 설치
      # 3. Flutter 의존성 설치 (flutter pub get)
      # 4. CocoaPods 설치 (pod install --repo-update)
      # 5. .env 파일 생성
      # 6. Flutter 분석 (flutter analyze)
      # 7. Flutter iOS 빌드 (flutter build ios --release --no-codesign)
      # 8. Ruby/Bundler 설치
      # 9. iOS 서명 설정 (인증서 + 프로비저닝 프로파일)
      # 10. App Store Connect API Key 생성
      # 11. Fastlane Beta 실행
      # 12. Keychain 정리
```

#### Fastlane 구성 요약

```ruby
# gear_freak_flutter/ios/fastlane/Fastfile

lane :beta do
  # 1. 최신 빌드 번호 가져와서 +1
  latest_testflight_build_number(...)
  increment_build_number(...)

  # 2. 코드 서명 설정 (수동 서명)
  update_code_signing_settings(
    use_automatic_signing: false,
    team_id: "TEAM_ID",
    profile_name: "프로파일명",
    code_sign_identity: "Apple Distribution"
  )

  # 3. iOS 앱 빌드
  build_app(
    export_method: "app-store",
    export_options: { signingStyle: "manual", ... }
  )

  # 4. TestFlight 업로드
  upload_to_testflight(skip_waiting_for_build_processing: true)
end
```

---

### 🔧 해결한 주요 이슈들

---

#### 이슈 1: AuthKey.p8 파일 경로 오류

**에러 메시지:**
```
❌ AuthKey.p8 파일을 찾을 수 없습니다
```

**원인:** Fastfile에서 상대 경로로 AuthKey.p8을 참조했으나, 실행 디렉토리가 달라서 파일을 찾지 못함

**Before (문제 상황)**
```ruby
key_filepath = "AuthKey.p8"
```

**After (해결)**
```ruby
# 절대 경로로 변환
key_filepath = File.expand_path("AuthKey.p8", __dir__)
```

---

#### 이슈 2: 인증서 Import 후 codesign 접근 불가

**에러 메시지:**
```
errSecInternalComponent
```

**원인:** macOS Keychain에 인증서를 import했지만, codesign 프로세스가 private key에 접근할 수 있는 권한이 없음

**Before (문제 상황)**
```bash
security import $CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
# → codesign 접근 시 errSecInternalComponent 에러
```

**After (해결)**
```bash
# 인증서 import
security import $CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH

# codesign이 private key에 접근할 수 있도록 partition list 설정
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
```

---

#### 이슈 3: 프로비저닝 프로파일 UUID 불일치

**에러 메시지:**
```
No provisioning profile matching 'GearFreak Production' found
```

**원인:** 프로비저닝 프로파일 파일명이 UUID와 일치하지 않아 Xcode가 인식하지 못함

**Before (문제 상황)**
```bash
# 임의의 파일명으로 저장
cp $PP_PATH ~/Library/MobileDevice/Provisioning\ Profiles/build_pp.mobileprovision
```

**After (해결)**
```bash
# UUID 추출 후 올바른 파일명으로 저장
PP_UUID=$(/usr/libexec/PlistBuddy -c "Print :UUID" /dev/stdin <<< $(security cms -D -i $PP_PATH))
cp $PP_PATH ~/Library/MobileDevice/Provisioning\ Profiles/$PP_UUID.mobileprovision
```

---

#### 이슈 4: Associated Domains Entitlement 오류

**에러 메시지:**
```
Provisioning profile doesn't include the com.apple.developer.associated-domains entitlement
```

**원인:** TestFlight용 프로비저닝 프로파일에 Associated Domains capability가 포함되어 있지 않음

**Before (문제 상황)**
```xml
<!-- Runner.entitlements -->
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:gear-freaks.com</string>
</array>
```

**After (해결)**
```xml
<!-- Associated Domains 제거 (TestFlight 빌드용) -->
<!-- 앱 심사 통과 후 Universal Links 필요 시 추가 -->
```

**참고:** Associated Domains를 사용하려면:
1. Apple Developer에서 App ID에 Associated Domains capability 추가
2. 프로비저닝 프로파일 재생성
3. 도메인 소유권 검증을 위한 AASA 파일 서버에 배포

---

#### 이슈 5: 자동 서명 vs 수동 서명 충돌

**에러 메시지:**
```
Automatic signing is disabled and unable to generate a profile
```

**원인:** CI 환경에서 자동 서명을 사용하면 Apple 계정 인증이 필요하므로 수동 서명으로 전환 필요

**Before (문제 상황)**
```ruby
build_app(
  # 자동 서명 시도 → CI에서 실패
)
```

**After (해결)**
```ruby
# 먼저 코드 서명 설정을 수동으로 변경
update_code_signing_settings(
  use_automatic_signing: false,
  path: "Runner.xcodeproj",
  team_id: "J26F9UUXYM",
  profile_name: "GearFreak Production",
  code_sign_identity: "Apple Distribution"
)

# 빌드 시 export_options에 수동 서명 설정 포함
build_app(
  export_method: "app-store",
  export_options: {
    method: "app-store",
    signingStyle: "manual",
    teamID: "J26F9UUXYM",
    provisioningProfiles: {
      "com.pyowonsik.gearFreakFlutter" => "GearFreak Production"
    }
  }
)
```

---

#### 이슈 6: APS Environment 불일치

**에러 메시지:**
```
Invalid aps-environment value. The value 'development' does not match the value 'production' specified in the provisioning profile.
```

**원인:** Runner.entitlements의 aps-environment가 development로 설정되어 있지만, App Store용 프로비저닝 프로파일은 production 환경을 요구

**Before (문제 상황)**
```xml
<!-- Runner.entitlements -->
<key>aps-environment</key>
<string>development</string>
```

**After (해결)**
```xml
<!-- Runner.entitlements -->
<key>aps-environment</key>
<string>production</string>
```

---

#### 이슈 7: TestFlight 버전 Train 종료

**에러 메시지:**
```
Invalid Pre-Release Train. The train version '1.0.1' is closed for new build submissions
```

**원인:** 이미 승인/배포된 버전(1.0.1)에는 새 빌드를 제출할 수 없음. 마케팅 버전을 올려야 함.

**Before (문제 상황)**
```yaml
# pubspec.yaml
version: 1.0.1+1  # 1.0.1은 이미 릴리즈됨
```

**After (해결)**
```yaml
# pubspec.yaml
version: 1.0.2+1  # 새 마케팅 버전으로 변경
```

**참고:** Flutter 버전 형식 `X.Y.Z+B`
- `X.Y.Z` = CFBundleShortVersionString (마케팅 버전)
- `B` = CFBundleVersion (빌드 번호)
- Fastlane의 `increment_build_number`는 빌드 번호만 증가시킴

---

### 📋 GitHub Secrets 설정

CI/CD 파이프라인에 필요한 GitHub Secrets:

| Secret 이름 | 설명 | 생성 방법 |
|------------|------|----------|
| `BUILD_CERTIFICATE_BASE64` | Apple Distribution 인증서 (.p12) | `cat certificate.p12 \| base64` |
| `P12_PASSWORD` | .p12 파일 비밀번호 | 인증서 내보내기 시 설정한 비밀번호 |
| `BUILD_PROVISION_PROFILE_BASE64` | App Store 프로비저닝 프로파일 | `cat profile.mobileprovision \| base64` |
| `KEYCHAIN_PASSWORD` | 임시 Keychain 비밀번호 | 임의의 안전한 문자열 |
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID | App Store Connect → Users → Keys |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | App Store Connect → Users → Keys |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | AuthKey.p8 내용 | API Key 생성 시 다운로드한 .p8 파일 내용 |

#### 인증서/프로파일 Base64 인코딩 방법

```bash
# 인증서 (.p12)
cat Certificates.p12 | base64 | pbcopy
# → GitHub Secrets에 BUILD_CERTIFICATE_BASE64로 저장

# 프로비저닝 프로파일 (.mobileprovision)
cat GearFreak_Production.mobileprovision | base64 | pbcopy
# → GitHub Secrets에 BUILD_PROVISION_PROFILE_BASE64로 저장

# API Key (.p8) - PEM 형식 그대로 저장
cat AuthKey_XXXXXX.p8 | pbcopy
# → GitHub Secrets에 APP_STORE_CONNECT_API_KEY_CONTENT로 저장
```

---

### 📊 CI/CD 파이프라인 흐름도

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflow                          │
├─────────────────────────────────────────────────────────────────────┤
│  1. 저장소 체크아웃                                                  │
│           ↓                                                         │
│  2. Flutter 환경 설정                                                │
│     - Flutter 설치                                                   │
│     - pub get                                                       │
│     - CocoaPods 설치                                                 │
│           ↓                                                         │
│  3. 환경 파일 생성                                                   │
│     - .env 파일 (BASE_URL, KAKAO_KEY 등)                            │
│           ↓                                                         │
│  4. 코드 품질 검사                                                   │
│     - flutter analyze                                               │
│           ↓                                                         │
│  5. Flutter iOS 빌드 (서명 없음)                                     │
│     - flutter build ios --release --no-codesign                     │
│           ↓                                                         │
│  6. iOS 서명 환경 구성                                               │
│     ┌──────────────────────────────────────────────────────┐        │
│     │  a. 임시 Keychain 생성                                │        │
│     │  b. .p12 인증서 import                                │        │
│     │  c. Partition list 설정 (codesign 접근 허용)          │        │
│     │  d. 프로비저닝 프로파일 설치 (UUID 기반 파일명)        │        │
│     │  e. AuthKey.p8 생성 (App Store Connect API)           │        │
│     └──────────────────────────────────────────────────────┘        │
│           ↓                                                         │
│  7. Fastlane Beta 실행                                              │
│     ┌──────────────────────────────────────────────────────┐        │
│     │  a. 최신 TestFlight 빌드 번호 조회                    │        │
│     │  b. 빌드 번호 +1 증가                                 │        │
│     │  c. 코드 서명 설정 (수동 서명)                        │        │
│     │  d. Xcode 빌드 (gym)                                  │        │
│     │  e. IPA 생성                                          │        │
│     │  f. TestFlight 업로드 (pilot)                         │        │
│     └──────────────────────────────────────────────────────┘        │
│           ↓                                                         │
│  8. 정리                                                            │
│     - 임시 Keychain 삭제                                            │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    App Store Connect                                │
├─────────────────────────────────────────────────────────────────────┤
│  1. 빌드 수신 (Processing)                                          │
│           ↓ (10~30분)                                               │
│  2. 빌드 처리 완료                                                   │
│           ↓                                                         │
│  3. 테스터에게 배포 가능                                             │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 🔍 디버깅 팁

#### 1. 로컬에서 Fastlane 테스트

```bash
cd gear_freak_flutter/ios

# 빌드만 테스트 (업로드 없음)
bundle exec fastlane build_only

# 전체 플로우 테스트
bundle exec fastlane beta
```

#### 2. 인증서 확인

```bash
# Keychain에 설치된 인증서 확인
security find-identity -v -p codesigning

# 프로비저닝 프로파일 확인
ls -la ~/Library/MobileDevice/Provisioning\ Profiles/
```

#### 3. 프로비저닝 프로파일 상세 정보

```bash
# 프로파일 내용 확인
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision
```

#### 4. GitHub Actions 실패 시 로그 확인

- Actions 탭에서 실패한 Job 클릭
- "빌드 로그 업로드" 아티팩트 다운로드
- `gym/Runner-Runner.log` 파일에서 상세 에러 확인

---

### 😊 해당 경험을 통해 알게된 점

**iOS 코드 서명의 복잡성**을 이해하게 되었습니다. 로컬 개발 환경에서는 Xcode가 자동으로 처리하는 서명 과정이 CI 환경에서는 모두 수동으로 설정해야 합니다.

**Keychain 접근 권한**의 중요성을 배웠습니다. 인증서를 import하는 것만으로는 충분하지 않고, codesign 프로세스가 private key에 접근할 수 있도록 partition list를 설정해야 합니다.

**Entitlements와 Provisioning Profile의 일치**가 필수라는 것을 알게 되었습니다. 앱에서 사용하는 capability(Push Notifications, Associated Domains 등)는 반드시 프로비저닝 프로파일에도 포함되어야 합니다.

**버전 관리 전략**의 중요성을 경험했습니다. App Store Connect에서 특정 버전이 릴리즈되면 해당 버전 train이 종료되므로, 새 빌드를 제출하려면 마케팅 버전을 올려야 합니다.

---

### 🛠️ 관련 기술

- **CI/CD**: GitHub Actions
- **빌드 자동화**: Fastlane (gym, pilot)
- **코드 서명**: Apple Distribution Certificate, Provisioning Profile
- **API 인증**: App Store Connect API (JWT)
- **Flutter**: iOS 빌드, pubspec.yaml 버전 관리

---

### 📁 관련 파일

- `.github/workflows/ios-testflight.yml` - GitHub Actions 워크플로우
- `gear_freak_flutter/ios/fastlane/Fastfile` - Fastlane 설정
- `gear_freak_flutter/ios/Runner/Runner.entitlements` - iOS Entitlements
- `gear_freak_flutter/pubspec.yaml` - Flutter 버전 설정

---

### 📚 참고 자료

- [GitHub Actions - iOS 앱 빌드 및 배포](https://docs.github.com/en/actions/deployment/deploying-xcode-applications)
- [Fastlane - iOS 배포 가이드](https://docs.fastlane.tools/getting-started/ios/setup/)
- [Apple - Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
