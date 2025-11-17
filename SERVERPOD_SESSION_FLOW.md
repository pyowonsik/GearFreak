# Serverpod Session과 getCurrentUser 동작 흐름

## 🔄 전체 흐름

### 1. 로그인 시 (클라이언트)

```dart
// 1. 서버에 인증 요청
final authenticate = await client.modules.auth.email.authenticate(
  email: email,
  password: password,
);

// 2. 클라이언트에 세션 등록 (클라이언트 측 저장)
await sessionManager.registerSignedInUser(
  authenticate.userInfo!,  // 서버에서 받은 UserInfo
  authenticate.keyId!,     // 인증 키 ID
  authenticate.key!,       // 인증 키
);
```

**클라이언트에 저장되는 것**:
- `SharedPreferences`에 인증 키 저장: `{keyId}:{key}`
- `SharedPreferences`에 사용자 정보 저장: `UserInfo` 객체

---

### 2. API 호출 시 (클라이언트 → 서버)

```dart
// 클라이언트에서 호출
final userInfo = await client.user.getCurrentUser();
```

**클라이언트 동작**:
1. `FlutterAuthenticationKeyManager.get()` 호출
2. `SharedPreferences`에서 인증 키 조회: `{keyId}:{key}`
3. HTTP 요청 헤더에 자동으로 인증 키 추가

---

### 3. 서버에서 처리 (서버 측)

```dart
// 서버의 getCurrentUser 엔드포인트
static Future<UserInfo> getCurrentUser(Session session) async {
  // 1. 클라이언트가 보낸 인증 키를 기반으로 인증 정보 조회
  final authenticationInfo = await session.authenticated;
  
  // 2. 서버의 데이터베이스에서 사용자 정보 조회
  final userInfo = await UserInfo.db.findById(
    session,
    authenticationInfo.userId,  // 인증 정보에서 userId 추출
  );
  
  return userInfo;  // 서버 DB에서 조회한 최신 정보 반환
}
```

**서버 동작**:
1. 클라이언트가 보낸 인증 키 (`{keyId}:{key}`)를 받음
2. 서버의 데이터베이스에서 인증 키 검증
   - `serverpod_user_authentication` 테이블에서 `keyId`와 `key` 확인
   - 유효하면 `AuthenticationInfo` 반환 (userId 포함)
3. `authenticationInfo.userId`를 사용해서 서버 DB에서 `UserInfo` 조회
4. **서버 DB의 최신 사용자 정보** 반환

---

## 📊 핵심 차이점

### `sessionManager.registerSignedInUser` (클라이언트)
- **위치**: 클라이언트 측
- **저장소**: `SharedPreferences` (클라이언트 디바이스)
- **목적**: 
  - 인증 키를 클라이언트에 저장 (다음 API 호출 시 사용)
  - 사용자 정보를 클라이언트에 캐시 (오프라인 상태에서도 사용 가능)
- **데이터**: 로그인 시점의 사용자 정보 (스냅샷)

### `session.authenticated` (서버)
- **위치**: 서버 측
- **저장소**: 서버 데이터베이스 (`serverpod_user_authentication` 테이블)
- **목적**: 
  - 클라이언트가 보낸 인증 키를 검증
  - 인증된 사용자의 `userId` 반환
- **데이터**: 인증 정보 (userId, scopes 등)

### `getCurrentUser` (서버)
- **위치**: 서버 측
- **저장소**: 서버 데이터베이스 (`serverpod_userinfo` 테이블)
- **목적**: 
  - 서버 DB에서 **최신** 사용자 정보 조회
  - `session.authenticated`에서 얻은 `userId`로 조회
- **데이터**: 서버 DB의 최신 사용자 정보

---

## 🎯 정리

### Q: `getCurrentUser`에서 반환하는 `UserInfo`는 `sessionManager.registerSignedInUser`에서 등록한 정보인가?

**A: 아니요!**

- `sessionManager.registerSignedInUser`: 클라이언트에 저장 (캐시용)
- `getCurrentUser`: 서버 DB에서 조회 (최신 정보)

### Q: 서버 단에서 session에 담긴 정보인가?

**A: 부분적으로 맞습니다!**

1. `session.authenticated`: 서버 DB의 인증 정보 (userId 추출용)
2. `getCurrentUser`: 서버 DB의 사용자 정보 (실제 반환 데이터)

---

## 🔍 상세 흐름도

```
[로그인]
클라이언트 → 서버: authenticate(email, password)
서버 → 클라이언트: UserInfo, keyId, key

[클라이언트 저장]
sessionManager.registerSignedInUser()
  ├─ SharedPreferences: 인증 키 저장
  └─ SharedPreferences: UserInfo 캐시 저장

[API 호출]
클라이언트 → 서버: getCurrentUser() + 인증 키 (자동 포함)

[서버 처리]
1. session.authenticated
   └─ 서버 DB (serverpod_user_authentication)에서 인증 키 검증
   └─ AuthenticationInfo 반환 (userId 포함)

2. UserInfo.db.findById(userId)
   └─ 서버 DB (serverpod_userinfo)에서 사용자 정보 조회
   └─ 최신 UserInfo 반환

[응답]
서버 → 클라이언트: 최신 UserInfo
```

---

## 💡 중요한 포인트

### 1. 두 개의 저장소
- **클라이언트**: `SharedPreferences` (캐시용)
- **서버**: 데이터베이스 (실제 데이터)

### 2. 데이터 일관성
- 클라이언트의 `sessionManager.signedInUser`는 **캐시**일 뿐
- `getCurrentUser()`는 항상 **서버 DB의 최신 정보**를 반환
- 사용자 정보가 변경되면 서버 DB에서 최신 정보를 가져옴

### 3. 인증 키의 역할
- 클라이언트: 인증 키를 저장하고 API 호출 시 자동으로 전송
- 서버: 인증 키를 검증하고 `userId`를 추출
- 인증 키 자체에는 사용자 정보가 없음 (단지 식별자)

---

## 📝 예시

### 시나리오: 사용자 이름 변경

1. **초기 상태**
   - 로그인: `userName = "홍길동"`
   - 클라이언트 캐시: `userName = "홍길동"`
   - 서버 DB: `userName = "홍길동"`

2. **사용자 이름 변경** (다른 기기에서)
   - 서버 DB: `userName = "김철수"` (변경됨)
   - 클라이언트 캐시: `userName = "홍길동"` (아직 변경 안 됨)

3. **getCurrentUser() 호출**
   - 서버 DB에서 조회: `userName = "김철수"` ✅ (최신 정보)
   - 클라이언트 캐시: `userName = "홍길동"` ❌ (오래된 정보)

**결론**: `getCurrentUser()`는 항상 서버 DB의 최신 정보를 반환합니다!


