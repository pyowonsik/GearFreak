# Serverpod 이메일 인증 방식 비교

## 1. Serverpod 공식 이메일 인증 플로우

### 단계별 프로세스

#### 1단계: `createAccountRequest()`
```dart
// client.modules.auth.email.createAccountRequest(userName, email, password)
// → Emails.createAccountRequest() 호출

// 내부 동작:
// 1. EmailCreateAccountRequest 테이블에 임시 저장
// 2. Emails.generatePasswordHash(password)로 비밀번호 해시 생성
// 3. 인증 코드 생성 (_generateVerificationCode())
// 4. 이메일 전송 (AuthConfig.current.sendValidationEmail)
```

**데이터베이스 저장:**
- `EmailCreateAccountRequest` 테이블:
  - `userName`
  - `email`
  - `hash` (해시된 비밀번호)
  - `verificationCode`

#### 2단계: `createAccount()`
```dart
// client.modules.auth.email.createAccount(email, verificationCode)
// → Emails.tryCreateAccount() 호출

// 내부 동작:
// 1. EmailCreateAccountRequest에서 인증 코드 확인
// 2. Emails.createUser() 호출
// 3. UserInfo 생성
// 4. EmailAuth 생성 (이미 해시된 비밀번호 사용)
// 5. EmailCreateAccountRequest 삭제
```

**최종 데이터베이스 저장:**
- `UserInfo` 테이블: 사용자 기본 정보
- `EmailAuth` 테이블: 이메일과 해시된 비밀번호

---

## 2. kobic 프로젝트 방식

### 공식 API 사용 (정상 플로우)

```dart
// 1. 회원가입 요청
final result = await podService.email.createAccountRequest(
  userName,
  email,
  password,
);

// 2. 이메일 인증 코드 입력 후
final userInfo = await podService.email.createAccount(
  email,
  verificationCode,
);
```

**특징:**
- ✅ 공식 API 사용
- ✅ 이메일 인증 필수
- ✅ 보안성 높음

---

## 3. 현재 프로젝트 (gear_freak) 방식

### 개발용: 이메일 인증 생략

```dart
// signupWithoutEmailVerification() - 개발용
Future<UserInfo> signupWithoutEmailVerification(
  Session session, {
  required String userName,
  required String email,
  required String password,
}) async {
  // 1. 이메일 중복 확인
  final existingEmailAuth = await EmailAuth.db.findFirstRow(...);
  
  // 2. 비밀번호 해시 생성 (공식 방식과 동일)
  final passwordHash = await Emails.generatePasswordHash(password);
  
  // 3. UserInfo 생성
  final userInfo = UserInfo(...);
  final savedUserInfo = await UserInfo.db.insertRow(session, userInfo);
  
  // 4. EmailAuth 생성
  final emailAuth = EmailAuth(
    userId: savedUserInfo.id!,
    email: email,
    hash: passwordHash,
  );
  await EmailAuth.db.insertRow(session, emailAuth);
  
  return savedUserInfo;
}
```

**특징:**
- ⚠️ 공식 API 우회 (개발용)
- ⚠️ 이메일 인증 생략
- ✅ 비밀번호 해시 방식은 공식과 동일 (`Emails.generatePasswordHash()`)

---

## 4. 핵심 차이점

| 항목 | 공식 방식 | 현재 프로젝트 (개발용) |
|------|----------|---------------------|
| **API 사용** | `createAccountRequest` → `createAccount` | 커스텀 엔드포인트 |
| **이메일 인증** | ✅ 필수 | ❌ 생략 |
| **비밀번호 해시** | `Emails.generatePasswordHash()` | `Emails.generatePasswordHash()` ✅ |
| **임시 저장** | `EmailCreateAccountRequest` 테이블 | 없음 |
| **최종 저장** | `UserInfo` + `EmailAuth` | `UserInfo` + `EmailAuth` ✅ |
| **보안성** | 높음 | 낮음 (개발용) |

---

## 5. 결론

### 공식 방식의 내부 동작
1. `createAccountRequest`: 비밀번호 해시 생성 → `EmailCreateAccountRequest`에 임시 저장
2. `createAccount`: 인증 코드 확인 → `Emails.createUser()` 호출
3. `createUser()`: `UserInfo` 생성 → `EmailAuth` 생성 (해시된 비밀번호 사용)

### 현재 프로젝트 방식
- 공식 API의 내부 로직을 직접 구현
- 이메일 인증 단계만 생략
- **비밀번호 해시 방식은 공식과 동일** (`Emails.generatePasswordHash()`)

### 프로덕션 환경 권장사항
- ✅ 공식 API 사용 (`createAccountRequest` → `createAccount`)
- ✅ 이메일 인증 필수
- ✅ `AuthConfig`에서 `sendValidationEmail` 설정 필요


