# 소셜 로그인 설정 및 구현 가이드

이 문서는 Gear Freak 앱의 구글, 카카오, 애플 로그인 설정 및 구현 과정을 설명합니다.

## 목차

1. [구글 로그인](#구글-로그인)
2. [카카오 로그인](#카카오-로그인)
3. [애플 로그인](#애플-로그인)
4. [공통 구현 패턴](#공통-구현-패턴)
5. [계정 연결 방식](#계정-연결-방식)

---

## 구글 로그인

### 특징

- **Firebase Auth 기본 지원**: Firebase가 구글을 기본 지원
- **플랫폼**: iOS, Android 모두 지원
- **인증 방식**: Firebase Auth를 거쳐서 Serverpod Firebase 인증 사용

### 설정 과정

#### 1. Google Cloud Console 설정

1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 프로젝트 선택: `gear-freak`
3. **API 및 서비스** > **OAuth 동의 화면** 설정 (최초 1회)
4. **API 및 서비스** > **사용자 인증 정보**에서 OAuth 클라이언트 ID 생성:
   - iOS 클라이언트 ID
   - Android 클라이언트 ID
   - 웹 애플리케이션 클라이언트 ID (서버용)

#### 2. Firebase Console 설정

1. Firebase Console → Authentication → Sign-in method
2. **Google** 활성화
3. 자동으로 설정됨 (추가 설정 불필요)

#### 3. iOS 설정

1. `Info.plist`에 클라이언트 ID 추가:

   ```xml
   <key>GIDClientID</key>
   <string>YOUR_IOS_CLIENT_ID</string>
   ```

2. `REVERSED_CLIENT_ID`를 URL Scheme으로 추가

#### 4. Android 설정

1. `google-services.json`에 OAuth 클라이언트 정보 포함
2. SHA-1 인증서 지문 등록

#### 5. 서버 설정

자세한 내용은 `gear_freak_server/docs/GOOGLE_SERVER_SETUP.md` 참고

- `config/google_client_secret.json` 파일 생성
- 웹 애플리케이션 클라이언트 ID와 시크릿 저장

### 구현 흐름

```
1. GoogleSignIn → 구글 ID Token 획득
2. Firebase Auth (GoogleAuthProvider) → Firebase ID Token 획득
3. Serverpod Firebase 인증 (modules.auth.firebase.authenticate)
   → UserInfo 자동 생성 + 인증 키 발급
4. 세션 등록 (sessionManager.registerSignedInUser)
5. User 테이블 생성/조회 (getOrCreateUserAfterGoogleLogin)
```

### 코드 위치

- **클라이언트**: `lib/feature/auth/data/datasource/auth_remote_datasource.dart` - `loginWithGoogle()`
- **서버**: `lib/src/feature/auth/service/auth_service.dart` - `getOrCreateUserAfterGoogleLogin()`

---

## 카카오 로그인

### 특징

- **Firebase Auth 미지원**: Firebase가 카카오를 기본 지원하지 않음
- **플랫폼**: iOS, Android 모두 지원
- **인증 방식**: 서버에서 카카오 API를 직접 호출하여 커스텀 인증

### 설정 과정

#### 1. 카카오 디벨로퍼 설정

1. [카카오 디벨로퍼](https://developers.kakao.com/) 접속
2. 내 애플리케이션 선택
3. **앱 키** 확인:
   - REST API 키
   - 네이티브 앱 키 (iOS/Android)

#### 2. 플랫폼 설정

**iOS:**

- Bundle ID 등록: `com.pyowonsik.gearFreakFlutter`
- URL Scheme 등록: `kakao{REST_API_KEY}`

**Android:**

- 패키지 이름 등록: `com.pyowonsik.gearFreakFlutter`
- 키 해시 등록

#### 3. Firebase Console 설정

- **불필요**: 카카오는 Firebase를 거치지 않음

### 구현 흐름

```
1. kakao_flutter_sdk → 카카오 Access Token 획득
2. 서버 엔드포인트 호출 (authenticateWithKakao)
   → 서버에서 카카오 API 호출 (https://kapi.kakao.com/v2/user/me)
   → 카카오 토큰 검증 및 사용자 정보 조회
   → UserInfo 생성 + 인증 키 발급
3. 세션 등록 (sessionManager.registerSignedInUser)
4. User 테이블 생성/조회 (getOrCreateUserAfterKakaoLogin)
```

### 코드 위치

- **클라이언트**: `lib/feature/auth/data/datasource/auth_remote_datasource.dart` - `loginWithKakao()`
- **서버**:
  - `lib/src/feature/auth/service/auth_service.dart` - `authenticateWithKakao()`, `getOrCreateUserAfterKakaoLogin()`
  - `lib/src/feature/auth/endpoint/auth_endpoint.dart` - `authenticateWithKakao()`, `getOrCreateUserAfterKakaoLogin()`

### 서버에서 카카오 API 호출

```dart
// 서버에서 카카오 API 직접 호출
final response = await http.get(
  Uri.parse('https://kapi.kakao.com/v2/user/me'),
  headers: {
    'Authorization': 'Bearer $accessToken',
  },
);
```

---

## 애플 로그인

### 특징

- **Firebase Auth 기본 지원**: Firebase가 애플을 기본 지원
- **플랫폼**: iOS만 지원 (Android 미지원)
- **인증 방식**: Firebase Auth를 거쳐서 Serverpod Firebase 인증 사용 (구글과 동일)

### 설정 과정

#### 1. Apple Developer 설정

**1-1. App ID에 Sign In with Apple 활성화**

1. [Apple Developer](https://developer.apple.com) 접속
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. App ID 선택: `com.pyowonsik.gearFreakFlutter`
4. **Sign In with Apple** 체크박스 활성화
5. **Save**

**1-2. Service ID 생성 (Firebase용)**

1. **Identifiers** → **+** 버튼 → **Services IDs** 선택
2. **Description**: `Gear Freak Firebase Auth` (또는 원하는 이름)
3. **Identifier**: `com.pyowonsik.gearFreakFlutter.auth` (또는 원하는 형식)
4. **Continue** → **Register**

**1-3. Service ID에 Sign In with Apple 설정**

1. 생성한 Service ID 클릭
2. **Sign In with Apple** 체크 → **Configure** 클릭
3. **Primary App ID**: `com.pyowonsik.gearFreakFlutter` 선택
4. **Website URLs** 설정:
   - **Domains and Subdomains**: `gear-freak.firebaseapp.com` (Firebase 프로젝트 ID)
   - **Return URLs**: `https://gear-freak.firebaseapp.com/_/auth/handler`
5. **Save** → **Continue** → **Register**

**1-4. Apple Key 생성**

1. **Keys** → **+** 버튼
2. **Key Name**: `Firebase Apple Auth Key` (또는 원하는 이름)
3. **Sign In with Apple** 체크 → **Configure**
4. **Primary App ID**: `com.pyowonsik.gearFreakFlutter` 선택
5. **Save** → **Continue** → **Register**
6. **Download** 버튼 클릭 → `.p8` 파일 다운로드 (한 번만 가능)
7. **Key ID** 복사 (예: `B26L9ZK4CY`)

**1-5. Apple Team ID 확인**

1. Apple Developer 오른쪽 상단 계정 정보 클릭
2. **Team ID** 확인 (예: `J26F9UUXYM`)

#### 2. Firebase Console 설정

1. Firebase Console → Authentication → Sign-in method
2. **Apple** 활성화
3. 다음 정보 입력:
   - **Service ID**: `com.pyowonsik.gearFreakFlutter.auth`
   - **Apple Team ID**: 위에서 확인한 Team ID
   - **Key ID**: 위에서 복사한 Key ID
   - **Private key**: 다운로드한 `.p8` 파일 전체 내용 붙여넣기
     - `-----BEGIN PRIVATE KEY-----`부터 `-----END PRIVATE KEY-----`까지 포함
4. **저장**

#### 3. iOS 프로젝트 설정 (Xcode)

1. Xcode에서 `ios/Runner.xcworkspace` 열기
2. Runner 타겟 선택 → **Signing & Capabilities**
3. **+ Capability** → **Sign In with Apple** 추가
4. 자동으로 설정됨

#### 4. Flutter 패키지 추가

`pubspec.yaml`에 이미 추가되어 있음:

```yaml
dependencies:
  sign_in_with_apple: ^6.1.0
```

### 구현 흐름

```
1. SignInWithApple → 애플 ID Token 획득
2. Firebase Auth (OAuthProvider('apple.com')) → Firebase ID Token 획득
3. Serverpod Firebase 인증 (modules.auth.firebase.authenticate)
   → UserInfo 자동 생성 + 인증 키 발급
4. 세션 등록 (sessionManager.registerSignedInUser)
5. User 테이블 생성/조회 (getOrCreateUserAfterAppleLogin)
```

### 코드 위치

- **클라이언트**: `lib/feature/auth/data/datasource/auth_remote_datasource.dart` - `loginWithApple()`
- **서버**: `lib/src/feature/auth/service/auth_service.dart` - `getOrCreateUserAfterAppleLogin()`

---

## 공통 구현 패턴

### 클라이언트 구조

```
AuthRemoteDataSource (데이터 소스)
  ↓
AuthRepository (인터페이스)
  ↓
AuthRepositoryImpl (구현)
  ↓
LoginWithXxxUseCase (UseCase)
  ↓
AuthNotifier (상태 관리)
  ↓
LoginScreen (UI)
```

### 서버 구조

```
AuthEndpoint (엔드포인트)
  ↓
AuthService (비즈니스 로직)
  ↓
UserInfo (Serverpod Auth)
  ↓
User (비즈니스 모델)
```

---

## 계정 연결 방식

### 현재 구현 방식: 계정 연결 (Account Linking)

**동작 방식:**

- 같은 이메일이면 자동으로 계정 연결
- 다른 이메일이면 별도 계정 유지

**예시:**

```
사용자 A:
- 구글로 로그인: user@example.com → 계정 생성 (user=1)
- 애플로 로그인: user@example.com → 기존 계정과 연결 (user=1)
결과: ✅ 하나의 계정으로 구글/애플 모두 사용 가능
```

**장점:**

- 사용자 편의성: 하나의 계정으로 모든 소셜 로그인 사용
- 데이터 일관성: 같은 사용자 데이터 유지
- 일반적인 UX 패턴

---

## 구글 vs 카카오 vs 애플 비교

| 구분              | 구글                                | 카카오                                                         | 애플                               |
| ----------------- | ----------------------------------- | -------------------------------------------------------------- | ---------------------------------- |
| **Firebase 지원** | ✅ 기본 지원                        | ❌ 미지원                                                      | ✅ 기본 지원                       |
| **플랫폼**        | iOS, Android                        | iOS, Android                                                   | iOS만                              |
| **서버 인증**     | Serverpod Firebase 인증             | 커스텀 인증 (카카오 API 직접 호출)                             | Serverpod Firebase 인증            |
| **엔드포인트**    | `getOrCreateUserAfterGoogleLogin()` | `authenticateWithKakao()` + `getOrCreateUserAfterKakaoLogin()` | `getOrCreateUserAfterAppleLogin()` |
| **설정 복잡도**   | 중간                                | 낮음                                                           | 높음                               |
| **코드 복잡도**   | 낮음 (Firebase가 처리)              | 중간 (서버에서 직접 처리)                                      | 낮음 (Firebase가 처리)             |

---

## 주요 차이점

### 구글/애플 (Firebase 사용)

1. **클라이언트**: 소셜 SDK → Firebase Auth → Serverpod Firebase 인증
2. **서버**: `getOrCreateUserAfterXxxLogin()` 엔드포인트만 필요
3. **특징**: Firebase가 토큰 검증 및 UserInfo 생성 자동 처리

### 카카오 (커스텀 인증)

1. **클라이언트**: 카카오 SDK → 서버 엔드포인트 호출
2. **서버**:
   - `authenticateWithKakao()`: 카카오 API 호출 + UserInfo 생성 + 인증 키 발급
   - `getOrCreateUserAfterKakaoLogin()`: User 테이블 생성/조회
3. **특징**: 서버에서 카카오 API를 직접 호출하여 토큰 검증

---

## 환경 변수 설정

### 클라이언트 (`.env`)

```env
# 구글
GOOGLE_SERVER_CLIENT_ID=your_google_web_client_id

# 카카오
KAKAO_NATIVE_APP_KEY=your_kakao_native_app_key
```

### 서버

- `config/google_client_secret.json`: 구글 OAuth 클라이언트 시크릿
- `config/fcm-service-account.json`: Firebase 서비스 계정 키 (Firebase 인증용)

---

## 참고 문서

- 구글 로그인 상세 설정: `gear_freak_flutter/docs/GOOGLE_SIGN_IN_SETUP.md`
- 구글 서버 설정: `gear_freak_server/docs/GOOGLE_SERVER_SETUP.md`
- 카카오 서버 설정: `gear_freak_server/docs/GOOGLE_SERVER_SETUP.md` (참고)

---

## 문제 해결

### 애플 로그인 시 구글 계정으로 연결되는 문제

**원인**: Firebase Auth가 같은 이메일이면 자동으로 계정을 연결함

**해결**: 현재는 계정 연결 방식으로 구현되어 있음 (의도된 동작)

- 같은 이메일이면 하나의 계정으로 연결
- 다른 이메일이면 별도 계정 유지

### 카카오 OAuth 딥링크 파싱 에러

**원인**: 앱의 딥링크 핸들러가 카카오 OAuth 딥링크를 처리하려고 함

**해결**: `DeepLinkService`에서 카카오 OAuth 딥링크를 무시하도록 처리

- `scheme.startsWith('kakao') && host == 'oauth'`인 경우 무시

---

## 다음 단계

모든 소셜 로그인 구현이 완료되었습니다. 다음 작업:

1. ✅ 구글 로그인
2. ✅ 카카오 로그인
3. ✅ 애플 로그인
4. 🔄 가드에서 라우팅 처리로 리팩토링 (선택사항)
