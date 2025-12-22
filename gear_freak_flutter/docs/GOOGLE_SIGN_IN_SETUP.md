# Google Sign In 설정 가이드

## 사전 준비: OAuth 동의 화면 설정

OAuth 클라이언트 ID를 생성하기 전에 먼저 OAuth 동의 화면을 설정해야 합니다.

### 1. OAuth 동의 화면 설정

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 프로젝트 선택: `gear-freak`
3. **API 및 서비스** > **OAuth 동의 화면**으로 이동
4. **외부** 또는 **내부** 선택 (일반적으로 **외부** 선택)
5. **만들기** 클릭

### 2. 앱 정보 입력

**1단계: 앱 정보**

- **앱 이름** \*: `장비빨` (또는 원하는 앱 이름)
- **사용자 지원 이메일** \*: 본인의 이메일 주소 선택
- **다음** 클릭

**2단계: 대상**

- **앱 로고**: 선택사항 (나중에 추가 가능)
- **앱 홈페이지 링크**: 선택사항
- **개인정보처리방침 링크**: 선택사항 (필요시 추가)
- **서비스 약관 링크**: 선택사항
- **승인된 도메인**: 선택사항
- **개발자 연락처 정보** \*: 본인의 이메일 주소
- **저장 후 계속** 클릭

**3단계: 범위**

- **범위 추가 또는 삭제** 클릭
- 다음 범위 추가:
  - `email`
  - `profile`
  - `openid`
- **업데이트** 클릭
- **저장 후 계속** 클릭

**4단계: 테스트 사용자** (외부 앱인 경우)

- 테스트 사용자로 사용할 이메일 주소 추가 (선택사항)
- **저장 후 계속** 클릭

**5단계: 요약**

- 정보 확인 후 **대시보드로 돌아가기** 클릭

### 3. OAuth 동의 화면 설정 완료 확인

OAuth 동의 화면이 설정되면 "OAuth 동의 화면" 페이지에서 설정된 정보를 확인할 수 있습니다.

## iOS 설정

### 1. Google Cloud Console에서 OAuth 클라이언트 ID 생성

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 프로젝트 선택: `gear-freak`
3. **API 및 서비스** > **사용자 인증 정보**로 이동
4. **+ 사용자 인증 정보 만들기** > **OAuth 클라이언트 ID** 선택
5. **애플리케이션 유형**: iOS 선택
6. **이름**: `gear-freak-ios` (또는 원하는 이름)
7. **번들 ID**: `com.pyowonsik.gearFreakFlutter`
8. **만들기** 클릭

### 2. 생성된 클라이언트 ID 확인

생성 후 다음과 같은 정보가 표시됩니다:

- **클라이언트 ID**: `123456789-abcdefghijklmnop.apps.googleusercontent.com` 형식
- **클라이언트 보안 비밀**: iOS는 필요 없음

### 3. Info.plist 설정

`gear_freak_flutter/ios/Runner/Info.plist` 파일에 다음을 추가:

```xml
<key>GIDClientID</key>
<string>YOUR_CLIENT_ID_HERE</string>
```

예시:

```xml
<key>GIDClientID</key>
<string>123456789-abcdefghijklmnop.apps.googleusercontent.com</string>
```

### 4. REVERSED_CLIENT_ID를 URL Scheme으로 추가

`Info.plist`의 `CFBundleURLTypes` 배열에 `REVERSED_CLIENT_ID`를 추가합니다.

`REVERSED_CLIENT_ID`는 클라이언트 ID를 역순으로 만든 값입니다.
예: `123456789-abcdefghijklmnop.apps.googleusercontent.com` → `com.googleusercontent.apps.abcdefghijklmnop-123456789`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>gearfreak</string>
            <string>REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

또는 별도의 URL Type으로 추가:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>gearfreak</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 5. GoogleService-Info.plist 업데이트 (선택사항)

Firebase Console에서 `GoogleService-Info.plist`를 다시 다운로드하면 `REVERSED_CLIENT_ID`가 포함될 수 있습니다.

## Android 설정

### 1. Google Cloud Console에서 OAuth 클라이언트 ID 생성

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 프로젝트 선택: `gear-freak`
3. **API 및 서비스** > **사용자 인증 정보**로 이동
4. **+ 사용자 인증 정보 만들기** > **OAuth 클라이언트 ID** 선택
5. **애플리케이션 유형**: Android 선택
6. **이름**: `gear-freak-android` (또는 원하는 이름)
7. **패키지 이름**: `com.pyowonsik.gearFreakFlutter`
8. **SHA-1 인증서 지문**: 앱 서명 인증서의 SHA-1 지문 추가
   - 디버그 키스토어: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
9. **만들기** 클릭

### 2. google-services.json 업데이트

Firebase Console에서 `google-services.json`을 다시 다운로드하면 OAuth 클라이언트 정보가 포함됩니다.

## 서버 설정

서버 측에서도 Google OAuth 클라이언트 시크릿이 필요합니다.

자세한 내용은 `gear_freak_server/docs/GOOGLE_SERVER_SETUP.md`를 참고하세요.

**요약:**
1. Google Cloud Console에서 **웹 애플리케이션** 타입의 OAuth 클라이언트 ID 생성
2. 클라이언트 ID와 시크릿을 `gear_freak_server/config/google_client_secret.json` 파일로 저장

## 참고사항

- OAuth 클라이언트 ID는 iOS, Android, 서버(웹 애플리케이션) 각각 별도로 생성해야 합니다.
- `REVERSED_CLIENT_ID`는 클라이언트 ID의 도메인 부분을 역순으로 만든 값입니다.
- 개발 환경과 프로덕션 환경에서 다른 클라이언트 ID를 사용할 수 있습니다.
