# Google Sign In 서버 설정 가이드

## 서버 측 Google OAuth 클라이언트 시크릿 설정

Serverpod Auth는 Google 로그인을 위해 서버 측에서 Google OAuth 클라이언트 시크릿이 필요합니다.

### 1. Google Cloud Console에서 웹 애플리케이션 OAuth 클라이언트 생성

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 프로젝트 선택: `gear-freak`
3. **API 및 서비스** > **사용자 인증 정보**로 이동
4. **+ 사용자 인증 정보 만들기** > **OAuth 클라이언트 ID** 선택
5. **애플리케이션 유형**: **웹 애플리케이션** 선택
6. **이름**: `gear-freak-server` (또는 원하는 이름)
7. **승인된 리디렉션 URI**: 
   - 개발 환경: `http://localhost:8080/auth/google/callback`
   - 프로덕션 환경: `https://your-api-domain.com/auth/google/callback`
8. **만들기** 클릭

### 2. 클라이언트 ID와 시크릿 확인

생성 후 다음과 같은 정보가 표시됩니다:

- **클라이언트 ID**: `123456789-abcdefghijklmnop.apps.googleusercontent.com` 형식
- **클라이언트 보안 비밀**: `GOCSPX-xxxxxxxxxxxxx` 형식

⚠️ **중요**: 클라이언트 보안 비밀은 이 시점에서만 표시됩니다. 복사해서 안전하게 보관하세요.

### 3. google_client_secret.json 파일 생성

Google Cloud Console에서 다운로드한 JSON 파일을 그대로 사용하거나, `gear_freak_server/config/google_client_secret.json` 파일을 생성하고 다음 형식으로 작성:

```json
{
  "web": {
    "client_id": "YOUR_CLIENT_ID_HERE",
    "project_id": "YOUR_PROJECT_ID",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_secret": "YOUR_CLIENT_SECRET_HERE",
    "redirect_uris": ["http://localhost:8080/auth/google/callback"]
  }
}
```

⚠️ **중요**: Serverpod Auth는 `web` 섹션이 있는 형식을 기대합니다. Google Cloud Console에서 다운로드한 JSON 파일을 그대로 사용하는 것이 가장 간단합니다.

### 4. 파일 위치 확인

파일이 다음 위치에 있어야 합니다:

```
gear_freak_server/
└── config/
    └── google_client_secret.json
```

### 5. 서버 재시작

파일을 생성한 후 서버를 재시작하면 Google 로그인이 정상적으로 작동합니다.

## 대안: 환경 변수 사용

환경 변수를 사용하여 클라이언트 시크릿을 설정할 수도 있습니다:

- 환경 변수 이름: `serverpod_auth_googleClientSecret`
- 값: 클라이언트 시크릿 값

하지만 파일 방식이 더 간단하고 권장됩니다.

## 참고사항

- `google_client_secret.json` 파일은 민감한 정보를 포함하므로 Git에 커밋하지 마세요.
- `.gitignore`에 이미 추가되어 있습니다.
- 개발, 스테이징, 프로덕션 환경마다 다른 클라이언트 ID를 사용할 수 있습니다.
- 서버 측 클라이언트는 **웹 애플리케이션** 타입이어야 합니다 (iOS/Android 클라이언트와는 별개).

