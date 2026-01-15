# Flutter App Store/Play Store 첫 배포 가이드

> 작성일: 2026-01-12
> 목적: iOS App Store와 Android Play Store에 첫 수동 배포를 위한 상세 가이드

---

## 목차

1. [공통 준비물](#1-공통-준비물)
2. [iOS App Store Connect 등록](#2-ios-app-store-connect-등록)
3. [Android Play Store Console 등록](#3-android-play-store-console-등록)
4. [권장 순서 및 타임라인](#4-권장-순서-및-타임라인)
5. [주의사항 및 팁](#5-주의사항-및-팁)

---

## 1. 공통 준비물

### 1.1 개인정보처리방침 (Privacy Policy)

**필수 요구사항:**
- iOS와 Android 모두 **공개적으로 접근 가능한 URL** 필요
- PDF 형식 불가 (Google Play는 편집 가능한 문서 거부)
- 지역 제한(geofencing) 없이 전 세계에서 접근 가능해야 함

**호스팅 옵션:**

| 옵션 | 장점 | 단점 |
|------|------|------|
| **자체 웹사이트** | 완전한 제어권, 신뢰성 | 도메인/호스팅 비용 |
| **GitHub Pages** | 무료, 버전 관리 | 기술 지식 필요 |
| **Google Sites** | 무료, 쉬운 설정 | 커스터마이징 제한 |
| **TermsFeed/FreePrivacyPolicy** | 무료 생성 및 호스팅 | 일부 기능 유료 |
| **Notion (Public)** | 무료, 쉬운 편집 | 전문적이지 않을 수 있음 |

**추천:** 자체 웹사이트가 있다면 `/privacy` 경로에 호스팅. 없다면 [FreePrivacyPolicy.com](https://www.freeprivacypolicy.com/) 또는 [TermsFeed](https://www.termsfeed.com/)에서 생성 후 호스팅.

**개인정보처리방침 필수 포함 내용:**
- 수집하는 개인정보 항목
- 수집 목적 및 사용 방법
- 제3자 공유 여부
- 데이터 보관 기간
- 사용자 권리 (삭제 요청 등)
- 연락처 정보

---

### 1.2 앱 아이콘

**원본 이미지 요구사항:**
- **크기:** 1024x1024 픽셀 (정사각형)
- **형식:** PNG (투명 배경 없이)
- **품질:** 고해상도, 단순하고 명확한 디자인

**플랫폼별 특이사항:**

| 플랫폼 | 필수 크기 | 특이사항 |
|--------|----------|----------|
| **App Store** | 1024x1024 px | 투명 배경 불가, 자동으로 모서리 둥글게 처리 |
| **Play Store** | 512x512 px (최소) | 적응형 아이콘 지원 (foreground/background 분리) |

**Flutter 앱 아이콘 생성:**

`flutter_launcher_icons` 패키지 사용 (이미 프로젝트에 설정되어 있음):

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  image_path: "assets/app_icon.png"
  android: true
  ios: true
  remove_alpha_ios: true  # iOS는 투명 배경 불가
```

```bash
# 아이콘 생성
flutter pub run flutter_launcher_icons
```

---

### 1.3 스크린샷

#### iOS App Store 스크린샷 요구사항 (2025-2026)

**필수 크기:**
- **6.9인치 iPhone (필수):** 1290 x 2796 px
- **13인치 iPad (Universal 앱인 경우):** 2064 x 2752 px

> Apple이 자동으로 다른 화면 크기로 스케일링하므로, 위 두 가지만 제공하면 됨

**규칙:**
- 형식: JPEG 또는 PNG (투명 배경 불가, RGB 색상)
- 수량: 최소 1장, 최대 10장
- 앱 프리뷰 비디오도 같은 해상도 필요

#### Android Play Store 스크린샷 요구사항

**Phone 스크린샷:**
- **권장 크기:** 1080 x 1920 px (또는 1440 x 2560 px)
- **비율:** 9:16 (세로) 또는 16:9 (가로)
- **최소/최대:** 320px ~ 3840px (최대가 최소의 2배를 넘지 않아야 함)

**Tablet 스크린샷 (선택):**
- **7인치 태블릿:** 1200 x 1920 px
- **10인치 태블릿:** 1600 x 2560 px

**공통 규칙:**
- 형식: 24비트 PNG 또는 JPEG (투명 배경 불가)
- 파일 크기: 최대 8MB
- 수량: 최소 2장, 최대 8장 (디바이스 유형별)

#### 스크린샷 제작 팁

1. **실제 앱 화면 사용:** 목업이나 가짜 화면 사용 금지 (심사 거부 원인)
2. **핵심 기능 강조:** 첫 3장이 가장 중요 (사용자가 처음 보는 화면)
3. **일관된 스타일:** 프레임, 색상, 폰트 통일
4. **로컬라이징:** 한국어/영어 별도 스크린샷 권장

**추천 도구:**
- [AppScreens](https://appscreens.com/) - 스크린샷 프레임 생성
- [Figma](https://figma.com/) - 디자인 및 목업
- [Screenshot Studio](https://screenshotstudio.com/) - 앱스토어 스크린샷 전문

---

### 1.4 앱 정보 (메타데이터)

| 항목 | iOS | Android | 권장 길이 |
|------|-----|---------|----------|
| **앱 이름** | 30자 | 30자 | 핵심 키워드 포함, 간결하게 |
| **부제목** | 30자 | N/A | 앱의 핵심 가치 설명 |
| **짧은 설명** | N/A | 80자 | 앱 설치 결정에 영향 |
| **상세 설명** | 4000자 | 4000자 | 기능, 장점, 사용법 설명 |
| **키워드** | 100자 (쉼표 구분) | N/A | 검색 최적화용 |
| **프로모션 텍스트** | 170자 | N/A | 심사 없이 수정 가능 |
| **카테고리** | 1개 필수, 2개 선택 | 1개 | 쇼핑/라이프스타일 |

**Gear Freak 앱 예시:**

```
앱 이름: Gear Freak - 피트니스 중고거래
부제목: 헬스 운동용품 중고 직거래 마켓

짧은 설명 (Android):
피트니스 장비 중고거래 앱. 덤벨, 바벨, 러닝머신 등 운동용품을 안전하게 직거래하세요.

상세 설명:
Gear Freak은 피트니스 장비 전문 중고거래 플랫폼입니다.

주요 기능:
- 헬스 운동용품 등록 및 판매
- 실시간 채팅으로 간편한 소통
- 관심 상품 찜하기
- 안전한 거래를 위한 리뷰 시스템
- 카카오/네이버/구글/애플 간편 로그인

거래 가능한 품목:
덤벨, 바벨, 케틀벨, 풀업바, 벤치프레스, 러닝머신, 사이클, 로잉머신, 요가매트, 폼롤러 등

문의: support@gearfreak.com
```

---

## 2. iOS App Store Connect 등록

### 2.1 Apple Developer 계정 가입

#### 계정 유형 선택

| 유형 | 비용 | 요구사항 | 앱스토어 표시 |
|------|------|----------|--------------|
| **개인 (Individual)** | $99/년 | Apple ID, 본인 확인 | 개인 실명 |
| **기업 (Organization)** | $99/년 | D-U-N-S 번호, 법인 정보 | 회사명 |

**개인 계정 등록 절차:**
1. [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll) 접속
2. Apple ID로 로그인 (2단계 인증 필수)
3. 개인 정보 입력 (실명, 연락처)
4. 신분증 확인 (Apple Developer 앱 또는 웹에서)
5. $99 결제
6. **승인 시간:** 즉시 ~ 수시간

**기업 계정 등록 절차:**
1. D-U-N-S 번호 확인/신청 ([dnb.com](https://www.dnb.com/))
2. [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll) 접속
3. 기업 정보 입력 (법인명, 주소, D-U-N-S)
4. 법적 대리권 확인 (계약 체결 권한)
5. Apple 검증 (전화 또는 이메일)
6. $99 결제
7. **승인 시간:** 3~10 영업일

> **권장:** 개인 개발자는 **개인 계정**으로 시작. 나중에 기업 계정으로 전환 가능 (Apple 문의 필요)

---

### 2.2 Bundle ID 등록

Bundle ID는 앱의 고유 식별자로, **한번 설정하면 변경 불가**합니다.

**등록 절차:**

1. [developer.apple.com/account](https://developer.apple.com/account) 접속
2. **Certificates, Identifiers & Profiles** 클릭
3. 좌측 메뉴에서 **Identifiers** 선택
4. **+** 버튼 클릭
5. **App IDs** 선택 후 Continue
6. Platform: **iOS, tvOS, watchOS** 선택
7. **Explicit App ID** 선택
8. Description: `Gear Freak iOS App`
9. Bundle ID: `com.gearfreak.app` (역도메인 형식)
10. Capabilities 선택:
    - ✅ Push Notifications
    - ✅ Sign In with Apple
    - ✅ In-App Purchase (자동 활성화)
11. Continue → Register

**Bundle ID 명명 규칙:**
```
com.<회사명>.<앱이름>
예: com.gearfreak.app
예: com.yourcompany.gearfreak
```

---

### 2.3 App Store Connect에서 앱 생성

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) 접속
2. **My Apps** → **+** 버튼 → **New App** 클릭
3. 앱 정보 입력:
   - **Platforms:** iOS
   - **Name:** Gear Freak - 피트니스 중고거래
   - **Primary Language:** Korean
   - **Bundle ID:** 등록한 Bundle ID 선택
   - **SKU:** `gearfreak-ios-001` (내부 관리용, 자유롭게 설정)
   - **User Access:** Full Access
4. **Create** 클릭

---

### 2.4 앱 메타데이터 입력

**App Information 탭:**
- Category: **Shopping** (Primary), **Lifestyle** (Secondary)
- Content Rights: 저작권 정보
- Age Rating: 설문 응답 (채팅, 거래 기능 고려)

**App Store 탭 → Version Information:**
- Screenshots (6.9" iPhone 필수)
- App Preview (선택, 15~30초 비디오)
- Promotional Text
- Description
- Keywords
- Support URL
- Marketing URL (선택)

**App Store 탭 → App Privacy:**
- Privacy Policy URL 입력
- Data Collection 설문 응답 (앱이 수집하는 데이터 명시)

---

### 2.5 첫 빌드 업로드 (Xcode 통해)

#### 사전 준비

1. **Xcode 최신 버전 설치** (Mac 필수)
2. **개발 인증서 생성:**
   - Xcode → Settings → Accounts → Apple ID 추가
   - Manage Certificates → **+** → Apple Distribution

#### Flutter 앱 빌드

```bash
# 프로젝트 디렉토리로 이동
cd /Users/pyowonsik/Downloads/workspace/gear_freak/gear_freak_flutter

# 클린 빌드
flutter clean
flutter pub get

# iOS 빌드
flutter build ios --release
```

#### Xcode에서 Archive 및 업로드

1. **Xcode에서 프로젝트 열기:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **빌드 설정 확인:**
   - Product → Destination → **Any iOS Device (arm64)**
   - Runner 프로젝트 선택 → Signing & Capabilities
   - Team: 본인 개발자 계정 선택
   - Bundle Identifier: `com.gearfreak.app`

3. **Archive 생성:**
   - Product → Archive
   - 빌드 완료까지 대기 (수 분 소요)

4. **App Store에 업로드:**
   - Organizer 창에서 Archive 선택
   - **Distribute App** 클릭
   - **App Store Connect** 선택 → Next
   - **Upload** 선택 → Next
   - 기본 옵션 유지 → Next
   - **Upload** 클릭

5. **처리 대기:**
   - 업로드 후 10~30분 내에 처리 완료 이메일 수신
   - App Store Connect에서 빌드 확인 가능

---

### 2.6 TestFlight 배포

1. App Store Connect → **TestFlight** 탭
2. 업로드된 빌드 선택
3. **Export Compliance:** 암호화 사용 여부 응답
   - HTTPS만 사용: **No** 선택
   - 자체 암호화 구현: **Yes** 선택 후 문서 제출
4. **Test Information** 입력:
   - 테스트 목적, 로그인 정보 등
5. **Internal Testers:**
   - App Store Connect 계정 보유자 최대 100명
   - 그룹 생성 → 이메일로 초대
6. **External Testers:**
   - 최대 10,000명
   - **Beta App Review** 필요 (1~2일 소요)

---

### 2.7 앱 심사 제출

1. **App Store 탭** → **Submit for Review**
2. 심사 정보 입력:
   - **Version Release:** Manual / Automatic
   - **App Review Information:**
     - Contact (연락처)
     - Demo Account (테스트 계정 정보)
     - Notes (특별 설명)
3. **Submit** 클릭

**심사 소요 시간:**
- 일반적으로 24~48시간
- 첫 앱은 더 오래 걸릴 수 있음 (3~7일)
- 거부 시 수정 후 재제출

---

### 2.8 흔한 심사 거부 사유

| 거부 사유 | 설명 | 해결책 |
|----------|------|--------|
| **2.1 Performance** | 앱 충돌, 버그 | 철저한 테스트, 에러 핸들링 |
| **2.3 Metadata** | 부정확한 설명/스크린샷 | 실제 앱 화면 사용, 정확한 설명 |
| **4.2 Minimum Functionality** | 기능 부족, 웹뷰 래퍼 | 네이티브 기능 추가 |
| **5.1.1 Privacy** | 개인정보 처리방침 누락 | Privacy Policy URL 추가 |
| **3.1.1 In-App Purchase** | Apple 결제 시스템 우회 | IAP 사용 (해당 시) |

**심사 통과 팁:**
- 테스트 계정 정보 상세히 제공
- Demo 모드나 샘플 데이터 준비
- 앱 사용 가이드 노트에 작성
- 모든 기능이 정상 작동하는지 확인

---

## 3. Android Play Store Console 등록

### 3.1 Google Play Console 개발자 계정 가입

#### 계정 유형

| 유형 | 등록비 | 요구사항 | 심사 요건 |
|------|--------|----------|----------|
| **개인** | $25 (1회) | Google 계정, 신분증 | 12명 테스터 × 14일 |
| **조직** | $25 (1회) | Google 계정, 사업자 정보 | 없음 (바로 배포 가능) |

> **중요 (2023.11 이후):** 개인 계정은 프로덕션 배포 전 **12명의 테스터가 14일간 앱을 테스트**해야 함

**등록 절차:**

1. [play.google.com/console](https://play.google.com/console) 접속
2. Google 계정으로 로그인
3. 개발자 계정 유형 선택 (개인/조직)
4. 개발자 정보 입력:
   - Developer name (공개됨)
   - Email address
   - Phone number
   - Website (선택)
5. 신원 확인 (개인: 신분증, 조직: 사업자 정보)
6. $25 결제
7. **승인 시간:** 즉시 ~ 48시간

---

### 3.2 Play Console에서 앱 생성

1. Play Console → **Create app** 클릭
2. 앱 정보 입력:
   - **App name:** Gear Freak - 피트니스 중고거래
   - **Default language:** Korean (한국어)
   - **App or game:** App
   - **Free or paid:** Free
3. 선언 항목 체크:
   - Developer Program Policies 동의
   - US export laws 준수
4. **Create app** 클릭

---

### 3.3 앱 서명 키 설정

#### Play App Signing (권장)

2021년 8월부터 모든 신규 앱은 **Play App Signing** 필수 사용.

**작동 방식:**
- **Upload Key (업로드 키):** 개발자가 보관, AAB 서명용
- **App Signing Key (앱 서명 키):** Google이 보관, 최종 APK 서명용

**장점:**
- 업로드 키 분실 시 Google에 재발급 요청 가능
- 앱 서명 키는 Google 인프라에서 안전하게 보관
- Dynamic Delivery 최적화 가능

#### Upload Keystore 생성

```bash
# Keystore 생성 (Mac/Linux)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 정보 입력:
# - 비밀번호 (기억해야 함!)
# - 이름, 조직, 도시, 국가
```

#### Flutter 프로젝트 설정

**1. key.properties 파일 생성:**

```bash
# gear_freak_flutter/android/key.properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=upload
storeFile=/Users/pyowonsik/upload-keystore.jks
```

> **주의:** `key.properties`와 `upload-keystore.jks`는 절대 Git에 커밋하지 마세요!

**2. .gitignore 확인:**

```gitignore
# gear_freak_flutter/android/.gitignore
key.properties
*.jks
*.keystore
```

**3. build.gradle 수정:**

`gear_freak_flutter/android/app/build.gradle`:

```groovy
// android {} 블록 위에 추가
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... 기존 설정 ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... 기존 설정 ...
        }
    }
}
```

---

### 3.4 AAB 빌드 및 업로드

#### AAB 빌드

```bash
# 프로젝트 디렉토리
cd /Users/pyowonsik/Downloads/workspace/gear_freak/gear_freak_flutter

# 클린 빌드
flutter clean
flutter pub get

# Release AAB 빌드
flutter build appbundle --release
```

빌드 결과물: `build/app/outputs/bundle/release/app-release.aab`

#### Internal Testing Track에 업로드 (권장)

1. Play Console → 앱 선택 → **Testing** → **Internal testing**
2. **Create new release** 클릭
3. **App signing** 페이지에서 Play App Signing 활성화
4. **Upload** 클릭 → AAB 파일 선택
5. Release name: `1.0.0 (1) - Internal Test`
6. Release notes 입력
7. **Save** → **Review release** → **Start rollout to Internal testing**

**Internal Testing 특징:**
- 최대 100명 테스터
- 심사 없이 즉시 배포 (첫 릴리스는 심사 필요할 수 있음)
- Play Store에 노출되지 않음

---

### 3.5 앱 메타데이터 입력

**Dashboard → Grow → Store presence → Main store listing:**

1. **App details:**
   - App name
   - Short description (80자)
   - Full description (4000자)

2. **Graphics:**
   - App icon: 512x512 px
   - Feature graphic: 1024x500 px (Play Store 상단 배너)
   - Screenshots: 최소 2장 (Phone)
   - Video (선택): YouTube URL

3. **Categorization:**
   - App category: **Shopping**
   - Tags

**Dashboard → Policy → App content:**

1. **Privacy policy:** URL 입력
2. **Ads:** 광고 포함 여부
3. **App access:** 로그인 필요 시 테스트 계정 정보
4. **Content ratings:** IARC 설문 응답
5. **Target audience:** 타겟 연령대
6. **News apps:** 뉴스 앱 여부
7. **COVID-19 apps:** 해당 여부
8. **Data safety:** 수집 데이터 유형 선택

---

### 3.6 테스터 요구사항 (개인 계정)

**12 Testers × 14 Days 정책:**

2023년 11월 13일 이후 생성된 개인 계정은:
1. Closed testing track에서 **12명 이상의 테스터**가
2. **연속 14일 이상** 앱을 테스트해야
3. Production 배포가 가능

**테스터 확보 방법:**
- 가족, 친구에게 요청
- 온라인 커뮤니티 활용
- [TestersCommunity](https://www.testerscommunity.com/) 같은 서비스 이용

**Closed Testing 설정:**
1. **Testing** → **Closed testing** → **Create track**
2. 테스터 목록 생성 (이메일 주소)
3. AAB 업로드
4. 테스터에게 opt-in 링크 공유
5. 14일 대기

---

### 3.7 앱 심사 제출 (Production)

1. **Production** → **Create new release**
2. AAB 업로드 (또는 Closed testing에서 promote)
3. Release notes 입력
4. **Review release** → **Start rollout to Production**

**심사 소요 시간:**
- 일반적으로 1~3일
- 첫 앱은 최대 7일
- 복잡한 앱은 더 오래 걸릴 수 있음

---

### 3.8 흔한 심사 거부 사유

| 거부 사유 | 설명 | 해결책 |
|----------|------|--------|
| **Privacy Policy** | 개인정보처리방침 누락/부적절 | 유효한 URL 제공, 내용 보완 |
| **Deceptive behavior** | 오해의 소지가 있는 설명 | 정확한 메타데이터 작성 |
| **Permissions** | 불필요한 권한 요청 | 필수 권한만 요청, 사유 설명 |
| **Target audience** | 어린이 대상 정책 위반 | 연령대 설정 검토 |
| **Data safety** | 데이터 수집 선언 누락 | 정확한 데이터 유형 선택 |

---

## 4. 권장 순서 및 타임라인

### 4.1 권장 진행 순서

```
[Week 1] 준비 단계
├── Day 1-2: 개발자 계정 등록 (Apple + Google)
├── Day 3: 개인정보처리방침 작성 및 호스팅
├── Day 4-5: 앱 아이콘, 스크린샷 제작
└── Day 6-7: 앱 설명, 키워드 작성

[Week 2] iOS 등록
├── Day 8: Bundle ID 등록, App Store Connect 앱 생성
├── Day 9: 메타데이터 입력
├── Day 10: Xcode Archive & 업로드
├── Day 11: TestFlight 배포 및 테스트
└── Day 12-14: 심사 제출 및 대기

[Week 2-3] Android 등록
├── Day 8: Play Console 앱 생성
├── Day 9: 메타데이터 입력
├── Day 10: AAB 빌드 & Internal Testing 업로드
├── Day 11-24: Closed Testing (12명 × 14일) - 개인 계정만
└── Day 25+: Production 심사 제출

[Week 3-4] 심사 및 출시
├── iOS: 심사 통과 후 즉시 출시 가능
└── Android: 심사 통과 후 즉시 출시 가능
```

### 4.2 예상 소요 시간

| 단계 | iOS | Android (개인) | Android (조직) |
|------|-----|----------------|----------------|
| 계정 등록 | 즉시~수시간 | 즉시~48시간 | 즉시~48시간 |
| 앱 생성 | 10분 | 10분 | 10분 |
| 메타데이터 입력 | 1~2시간 | 1~2시간 | 1~2시간 |
| 첫 빌드 업로드 | 30분~1시간 | 30분 | 30분 |
| TestFlight/Internal | 즉시 | 즉시 | 즉시 |
| 테스터 요구사항 | 없음 | **14일** | 없음 |
| 심사 | 24~48시간 | 1~7일 | 1~7일 |
| **총 소요 시간** | **3~7일** | **17~25일** | **3~10일** |

### 4.3 병렬 진행 전략

```
Week 1:
├── [공통] 계정 등록, 자료 준비
├── [iOS] App Store Connect 설정 시작
└── [Android] Play Console 설정 + Closed Testing 시작 (14일 카운트)

Week 2:
├── [iOS] TestFlight → 심사 제출
└── [Android] 테스터 모집 및 테스트 진행 중

Week 3:
├── [iOS] 심사 통과 → 출시!
└── [Android] 14일 테스트 완료 → Production 심사

Week 4:
└── [Android] 심사 통과 → 출시!
```

**핵심 전략:** Android Closed Testing 14일 요구사항 때문에, **Android를 먼저 시작**하고 그 동안 iOS를 진행하면 전체 출시 시간을 단축할 수 있습니다.

---

## 5. 주의사항 및 팁

### 5.1 필수 체크리스트

#### 출시 전 최종 점검

- [ ] 앱이 모든 디바이스에서 크래시 없이 작동
- [ ] 모든 기능 정상 동작 확인
- [ ] 로그인/로그아웃 플로우 테스트
- [ ] 네트워크 오류 시 적절한 에러 메시지 표시
- [ ] 개인정보처리방침 URL 접근 가능
- [ ] 앱 내에서 개인정보처리방침 링크 제공
- [ ] 스크린샷이 실제 앱 화면과 일치
- [ ] 앱 설명이 실제 기능과 일치
- [ ] 테스트 계정 정보 준비 (심사용)

#### 보안 관련

- [ ] API 키, 시크릿이 코드에 하드코딩되어 있지 않음
- [ ] `.env` 파일이 `.gitignore`에 포함
- [ ] `key.properties`, keystore 파일이 Git에 포함되지 않음
- [ ] Firebase 설정 파일 보호

### 5.2 주요 팁

#### iOS

1. **TestFlight 먼저:** 항상 TestFlight에서 충분히 테스트 후 심사 제출
2. **심사 노트 활용:** 복잡한 기능은 심사 노트에 상세 설명
3. **Export Compliance:** 대부분의 앱은 "No" 선택 (HTTPS만 사용 시)
4. **버전 관리:** 심사 거부 시 Build number 증가 필요
5. **메타데이터 미리 준비:** 심사 중에는 수정 불가

#### Android

1. **Internal Track 먼저:** 빠른 테스트를 위해 Internal 사용
2. **AAB 필수:** APK 업로드 불가 (2021년 8월부터)
3. **키 백업 필수:** Upload keystore 분실 시 Google에 재발급 요청 가능
4. **단계적 출시:** Production은 10% → 50% → 100% 단계적 출시 권장
5. **Pre-launch report:** 자동 테스트 결과 확인

### 5.3 비용 요약

| 항목 | 비용 | 주기 |
|------|------|------|
| Apple Developer Program | $99 | 매년 |
| Google Play Console | $25 | 1회 (평생) |
| 개인정보처리방침 호스팅 | $0 ~ $10/월 | 월간 |
| 스크린샷 제작 도구 | $0 ~ $20/월 | 월간 |
| **첫해 총 비용** | **약 $124~** | - |

### 5.4 심사 거부 시 대응

1. **거부 사유 정확히 파악:** 이메일 및 Resolution Center 확인
2. **필요한 수정만 진행:** 불필요한 변경은 새로운 문제 유발 가능
3. **심사팀과 소통:** Reply to App Review로 질문 가능
4. **재제출 시 설명 추가:** 수정 사항 상세히 기재
5. **Appeal:** 부당한 거부라고 생각되면 이의 제기 가능

---

## 참고 자료

### 공식 문서
- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Google Play Developer Policy Center](https://play.google.com/about/developer-content-policy/)
- [Play Console Help](https://support.google.com/googleplay/android-developer/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)

### 유용한 도구
- [App Store Screenshot Generator](https://appscreens.com/)
- [Privacy Policy Generator](https://www.freeprivacypolicy.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Google Play Console](https://play.google.com/console/)

---

## 다음 단계: CI/CD 파이프라인

수동 배포가 완료되면, 다음 단계로 Fastlane + GitHub Actions를 이용한 CI/CD 파이프라인 구축을 권장합니다:

1. **Fastlane 설정:**
   - iOS: `fastlane match`로 인증서 관리
   - Android: `fastlane supply`로 배포 자동화

2. **GitHub Actions:**
   - PR 머지 시 자동 빌드
   - 태그 생성 시 자동 배포

3. **버전 관리:**
   - Semantic versioning
   - 자동 버전 증가

해당 내용은 별도 연구 문서로 작성 예정입니다.
