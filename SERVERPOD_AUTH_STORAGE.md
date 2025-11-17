# Serverpod 인증 저장 방식 설명

## 🔑 핵심 차이점

### 기존 방식 (JWT)

```dart
// FlutterSecureStorage 사용
await secureStorage.write(key: 'access_token', value: accessToken);
await secureStorage.write(key: 'refresh_token', value: refreshToken);

// API 호출 시 수동으로 헤더에 추가
headers: {
  'Authorization': 'Bearer $accessToken',
}
```

### Serverpod 방식

```dart
// SessionManager가 자동으로 관리
await sessionManager.registerSignedInUser(
  userInfo,
  keyId,
  key,
);

// API 호출 시 자동으로 인증 키 포함 (별도 작업 불필요)
final userInfo = await client.user.getCurrentUser();
```

---

## 📦 Serverpod의 내부 저장 구조

### 1. FlutterAuthenticationKeyManager

**위치**: `serverpod_auth_shared_flutter` 패키지

**저장 방식**:

- **저장소**: `SharedPreferences` (FlutterSecureStorage 아님!)
- **키**: `serverpod_authentication_key_{runMode}`
- **값**: `{keyId}:{authenticationKey}` 형식의 문자열

**코드**:

```dart
class FlutterAuthenticationKeyManager extends AuthenticationKeyManager {
  // SharedPreferences 사용
  final Storage _storage = SharedPreferenceStorage();

  @override
  Future<void> put(String key) async {
    // SharedPreferences에 저장
    await _storage.setString('serverpod_authentication_key_$runMode', key);
  }

  @override
  Future<String?> get() async {
    // SharedPreferences에서 조회
    return await _storage.getString('serverpod_authentication_key_$runMode');
  }
}
```

### 2. SessionManager

**저장 방식**:

- **사용자 정보**: `SharedPreferences`에 저장
  - 키: `serverpod_userinfo_key`
  - 값: `UserInfo` 객체 (JSON 직렬화)
- **인증 키**: `FlutterAuthenticationKeyManager`를 통해 저장

**코드**:

```dart
class SessionManager {
  late FlutterAuthenticationKeyManager keyManager;
  final Storage _storage = SharedPreferenceStorage();

  Future<void> registerSignedInUser(
    UserInfo userInfo,
    int authenticationKeyId,
    String authenticationKey,
  ) async {
    // 1. 인증 키를 KeyManager에 저장 (SharedPreferences)
    var key = '$authenticationKeyId:$authenticationKey';
    await keyManager.put(key);

    // 2. 사용자 정보를 SharedPreferences에 저장
    await _storeSharedPrefs();

    // 3. 스트리밍 연결 업데이트
    await caller.client.updateStreamingConnectionAuthenticationKey(key);
  }
}
```

---

## 🔄 동작 흐름

프론트엔드 (sessionManager)
↓
인증 키 저장 (SharedPreferences)
↓
API 호출 시 자동으로 헤더에 포함
↓
백엔드 (session.authenticated)
↓
인증 키 검증 → AuthenticationInfo 반환

### 로그인 시

1. `client.modules.auth.email.authenticate()` 호출
2. 서버에서 `UserInfo`, `keyId`, `key` 반환
3. `sessionManager.registerSignedInUser()` 호출
   - `FlutterAuthenticationKeyManager.put()` → SharedPreferences에 인증 키 저장
   - `_storeSharedPrefs()` → SharedPreferences에 사용자 정보 저장
4. 이후 모든 API 호출에 자동으로 인증 키 포함

### API 호출 시

```dart
// 인증 키가 자동으로 포함됨 (별도 작업 불필요)
final userInfo = await client.user.getCurrentUser();
```

**내부 동작**:

1. `Client`가 `FlutterAuthenticationKeyManager.get()` 호출
2. SharedPreferences에서 인증 키 조회
3. HTTP 요청 헤더에 자동으로 추가

### 로그아웃 시

```dart
await sessionManager.signOutDevice();
```

**내부 동작**:

1. 서버에 로그아웃 요청
2. `keyManager.remove()` → SharedPreferences에서 인증 키 삭제
3. `_storeSharedPrefs()` → SharedPreferences에서 사용자 정보 삭제

---

## 📊 비교표

| 항목          | 기존 방식 (JWT)                 | Serverpod 방식                           |
| ------------- | ------------------------------- | ---------------------------------------- |
| **저장소**    | FlutterSecureStorage            | SharedPreferences                        |
| **저장 내용** | accessToken, refreshToken       | authenticationKey (keyId:key 형식)       |
| **저장 키**   | `access_token`, `refresh_token` | `serverpod_authentication_key_{runMode}` |
| **관리 방식** | 수동 저장/조회/삭제             | SessionManager가 자동 관리               |
| **API 호출**  | 수동으로 헤더에 추가            | 자동으로 포함                            |
| **토큰 갱신** | 수동 refresh 로직 필요          | 자동 처리                                |
| **보안**      | FlutterSecureStorage (암호화)   | SharedPreferences (일반 저장)            |

---

## ⚠️ 중요 사항

### 1. SharedPreferences vs FlutterSecureStorage

- **Serverpod는 SharedPreferences 사용** (FlutterSecureStorage 아님)
- SharedPreferences는 암호화되지 않은 일반 저장소
- 하지만 Serverpod의 인증 키는 서버에서 관리되며, 만료 시간이 있어 상대적으로 안전

### 2. 자동 관리의 장점

- ✅ 토큰 저장/조회/삭제를 신경 쓸 필요 없음
- ✅ API 호출 시 자동으로 인증 키 포함
- ✅ 세션 만료 시 자동 처리
- ✅ 여러 기기 간 세션 관리 자동화

### 3. 직접 접근 불필요

- `SharedPreferences`에 직접 접근할 필요 없음
- `SessionManager`와 `FlutterAuthenticationKeyManager`가 모든 것을 처리
- `sessionManager.isSignedIn`으로 로그인 상태 확인
- `sessionManager.signedInUser`로 현재 사용자 정보 조회

---

## 💡 실제 사용 예시

### 로그인

```dart
// 1. 인증 요청
final authenticate = await client.modules.auth.email.authenticate(
  email: email,
  password: password,
);

// 2. 세션 등록 (자동으로 SharedPreferences에 저장됨)
await sessionManager.registerSignedInUser(
  authenticate.userInfo!,
  authenticate.keyId!,
  authenticate.key!,
);

// 끝! 이후 모든 API 호출에 자동으로 인증 키 포함
```

### API 호출

```dart
// 인증 키가 자동으로 포함됨 (별도 작업 불필요)
final userInfo = await client.user.getCurrentUser();
```

### 로그아웃

```dart
// 자동으로 SharedPreferences에서 삭제됨
await sessionManager.signOutDevice();
```

### 로그인 상태 확인

```dart
if (sessionManager.isSignedIn) {
  final user = sessionManager.signedInUser;
  // 사용자 정보 사용
}
```

---

## 🎯 결론

**Serverpod를 사용하면**:

- ✅ `FlutterSecureStorage`로 토큰을 수동 관리할 필요 없음
- ✅ `SessionManager`가 모든 것을 자동으로 처리
- ✅ API 호출 시 인증 키가 자동으로 포함됨
- ✅ 세션 관리가 간단해짐

**하지만**:

- ⚠️ SharedPreferences 사용 (암호화되지 않음)
- ⚠️ 기존 JWT 방식과는 다른 구조
- ⚠️ Serverpod의 인증 시스템에 종속됨

