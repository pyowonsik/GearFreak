# Serverpod 마이그레이션 가이드

## 프로젝트 비교 분석

### kobic 프로젝트 (Serverpod 기반)
- **인증 방식**: Session & Scope 기반 인증
- **데이터 모델**: `.spy.yaml` 파일로 정의
- **클라이언트 관리**: `PodService` 싱글톤 패턴
- **세션 관리**: `SessionManager` 사용

### gear_freak 프로젝트 (현재 상태)
- **인증 방식**: JWT 토큰 기반 (accessToken, refreshToken)
- **데이터 모델**: Dart 클래스로 정의된 Entity
- **클라이언트 관리**: 직접 `Client` 사용
- **토큰 저장**: `SharedPreferences`에 수동 저장

---

## 주요 변경사항

### 1. 인증 방식 변경: JWT → Session & Scope

#### ❌ 현재 방식 (JWT)
```dart
// gear_freak_flutter/lib/feature/auth/data/repository/auth_repository_impl.dart
class AuthRepositoryImpl {
  Future<User> login({required String email, required String password}) async {
    final data = await remoteDataSource.login(email: email, password: password);
    
    // JWT 토큰을 SharedPreferences에 저장
    await sharedPreferences.setString('access_token', data['accessToken']);
    await sharedPreferences.setString('refresh_token', data['refreshToken']);
    
    return User(
      id: data['id'],
      email: data['email'],
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }
}
```

#### ✅ Serverpod 방식 (Session & Scope)
```dart
// gear_freak_flutter/lib/core/service/pod_service.dart (새로 생성 필요)
class PodService {
  static final PodService _instance = PodService._();
  static PodService get instance => _instance;
  
  late Client client;
  late SessionManager sessionManager;
  
  factory PodService.initialize({required String baseUrl}) {
    _instance.client = Client(
      baseUrl,
      authenticationKeyManager: FlutterAuthenticationKeyManager(),
    )..connectivityMonitor = FlutterConnectivityMonitor();
    
    _instance.sessionManager = SessionManager(
      caller: _instance.client.modules.auth,
    );
    
    return _instance;
  }
}

// gear_freak_flutter/lib/feature/auth/data/repository/auth_repository_impl.dart
class AuthRepositoryImpl {
  final PodService podService;
  
  Future<UserInfo> login({required String email, required String password}) async {
    // Serverpod의 email 인증 사용
    final authenticate = await podService.email.authenticate(
      email: email,
      password: password,
    );
    
    if (authenticate.success && authenticate.userInfo != null) {
      // 세션 등록 (자동으로 인증 키 관리)
      await podService.sessionManager.registerSignedInUser(
        authenticate.userInfo!,
        authenticate.keyId!,
        authenticate.key!,
      );
      
      return authenticate.userInfo!;
    }
    
    throw Exception('로그인 실패');
  }
  
  Future<void> logout() async {
    // 세션 자동 정리
    await podService.sessionManager.signOutDevice();
  }
  
  bool get isAuthenticated => podService.sessionManager.isSignedIn;
}
```

#### 주요 차이점

| 항목 | JWT 방식 | Session & Scope 방식 |
|------|---------|---------------------|
| 토큰 저장 | SharedPreferences 수동 저장 | `FlutterAuthenticationKeyManager` 자동 관리 |
| 인증 상태 확인 | 토큰 존재 여부 확인 | `sessionManager.isSignedIn` |
| 토큰 갱신 | 수동 refresh 로직 필요 | 자동 처리 |
| 세션 관리 | 수동 관리 | `SessionManager`가 자동 관리 |

---

### 2. 데이터 모델 변경: Entity → .spy.yaml

#### ❌ 현재 방식 (Dart Entity)
```dart
// gear_freak_flutter/lib/feature/auth/domain/entity/user.dart
class User {
  final String id;
  final String email;
  final String? nickname;
  final String? accessToken;
  final String? refreshToken;
  
  const User({
    required this.id,
    required this.email,
    this.nickname,
    this.accessToken,
    this.refreshToken,
  });
}
```

#### ✅ Serverpod 방식 (.spy.yaml)
```yaml
# gear_freak_server/lib/src/feature/user/model/entities/user.spy.yaml
### 사용자 정보
class: User

table: user

fields:
  ### 인증 모듈에 저장된 사용자 정보
  userInfo: module:auth:UserInfo?, relation
  ### 닉네임
  nickname: String?
  ### 이메일
  email: String?
  ### 프로필 이미지 URL
  profileImageUrl: String?

indexes:
  user_info_id_unique_idx:
    fields: userInfoId
    unique: true
```

#### 생성된 Dart 클래스 (자동 생성)
```dart
// gear_freak_client/lib/src/protocol/user.dart (자동 생성됨)
class User extends SerializableEntity {
  final int? id;
  final UserInfo? userInfo;
  final String? nickname;
  final String? email;
  final String? profileImageUrl;
  
  // ... 자동 생성된 메서드들
}
```

#### 주요 차이점

| 항목 | Entity 방식 | .spy.yaml 방식 |
|------|------------|---------------|
| 정의 위치 | Flutter 프로젝트 | Server 프로젝트 |
| 코드 생성 | 수동 작성 | `serverpod generate` 자동 생성 |
| 타입 안정성 | 수동 관리 | 자동 생성으로 보장 |
| 서버-클라이언트 동기화 | 수동 동기화 필요 | 자동 동기화 |
| 데이터베이스 매핑 | 수동 ORM 설정 | 자동 테이블 생성 |

---

### 3. 엔드포인트 인증 처리

#### ❌ 현재 방식 (JWT 검증 필요)
```dart
// gear_freak_server/lib/src/feature/auth/endpoint/auth_endpoint.dart (가정)
class AuthEndpoint extends Endpoint {
  Future<User> getCurrentUser(Session session) async {
    // JWT 토큰을 헤더에서 추출하고 검증하는 로직 필요
    final token = session.httpRequest?.headers['authorization'];
    // ... JWT 검증 로직
  }
}
```

#### ✅ Serverpod 방식 (자동 인증)
```dart
// gear_freak_server/lib/src/feature/user/endpoint/user_endpoint.dart
class UserEndpoint extends Endpoint with AuthenticatedMixin {
  // requireLogin => true 자동 적용
  
  Future<User> getCurrentUser(Session session) async {
    // session.authenticated가 자동으로 설정됨
    final auth = await session.authenticated;
    if (auth == null) {
      throw Exception('인증이 필요합니다.');
    }
    
    // 사용자 정보 조회
    final user = await User.db.findFirstRow(
      session,
      where: (u) => u.userInfoId.equals(auth.userId),
    );
    
    return user!;
  }
  
  // Scope 기반 권한 체크
  @override
  Set<Scope> get requiredScopes => {Scope.user};
}
```

#### 인증 Mixin 사용법

```dart
// gear_freak_server/lib/src/common/authenticated_mixin.dart
mixin AuthenticatedMixin on Endpoint {
  @override
  bool get requireLogin => true;
}

mixin AdminMixin on Endpoint {
  @override
  bool get requireLogin => true;
  
  @override
  Set<Scope> get requiredScopes => {Scope.admin};
}

// 사용 예시
class UserEndpoint extends Endpoint with AuthenticatedMixin {
  // 자동으로 requireLogin => true 적용
}

class AdminEndpoint extends Endpoint with AdminMixin {
  // 자동으로 requireLogin => true, requiredScopes => {Scope.admin} 적용
}
```

---

### 4. 클라이언트 호출 방식 변경

#### ❌ 현재 방식
```dart
// gear_freak_flutter/lib/feature/auth/data/datasource/auth_remote_datasource.dart
class AuthRemoteDataSource {
  final Client client;
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // TODO: Serverpod 엔드포인트 호출
    // JWT 토큰을 헤더에 수동으로 추가해야 함
    return {
      'id': 'user_1',
      'email': email,
      'accessToken': 'dummy_token',
      'refreshToken': 'dummy_refresh',
    };
  }
}
```

#### ✅ Serverpod 방식
```dart
// gear_freak_flutter/lib/feature/auth/data/datasource/auth_remote_datasource.dart
class AuthRemoteDataSource {
  final PodService podService;
  
  Future<UserInfo> login({
    required String email,
    required String password,
  }) async {
    // Serverpod 인증 모듈 사용
    final authenticate = await podService.email.authenticate(
      email: email,
      password: password,
    );
    
    if (authenticate.success && authenticate.userInfo != null) {
      // 세션 자동 등록
      await podService.sessionManager.registerSignedInUser(
        authenticate.userInfo!,
        authenticate.keyId!,
        authenticate.key!,
      );
      
      return authenticate.userInfo!;
    }
    
    throw Exception('로그인 실패: ${authenticate.failReason}');
  }
  
  // 인증된 엔드포인트 호출 (자동으로 인증 키 포함)
  Future<User> getCurrentUser() async {
    // 인증 키가 자동으로 포함됨
    return await podService.client.user.getCurrentUser();
  }
}
```

---

## 마이그레이션 체크리스트

### 1. 서버 측 변경사항

- [ ] `serverpod_auth` 패키지 추가
- [ ] 인증 엔드포인트 설정 (email, google, apple 등)
- [ ] `.spy.yaml` 파일로 Entity 정의
- [ ] `serverpod generate` 실행하여 코드 생성
- [ ] `AuthenticatedMixin` 생성
- [ ] 엔드포인트에 인증 적용

### 2. 클라이언트 측 변경사항

- [ ] `serverpod_auth_client`, `serverpod_auth_shared_flutter` 패키지 추가
- [ ] `PodService` 클래스 생성
- [ ] `SessionManager` 초기화
- [ ] `AuthRepository`를 Session 기반으로 변경
- [ ] JWT 토큰 저장 로직 제거
- [ ] `SharedPreferences` 토큰 저장 코드 제거
- [ ] Entity 클래스를 생성된 Protocol 클래스로 교체

### 3. 데이터 모델 마이그레이션

- [ ] 기존 Entity를 `.spy.yaml`로 변환
- [ ] `serverpod generate` 실행
- [ ] 클라이언트 코드에서 생성된 클래스 사용
- [ ] 데이터베이스 마이그레이션 실행

---

## 예시: 완전한 마이그레이션 예제

### 서버 측

```dart
// gear_freak_server/lib/src/feature/user/endpoint/user_endpoint.dart
import 'package:serverpod/serverpod.dart';
import '../../common/authenticated_mixin.dart';
import '../model/entities/user.spy.yaml'; // generate 후 생성됨

class UserEndpoint extends Endpoint with AuthenticatedMixin {
  Future<User> getCurrentUser(Session session) async {
    final auth = await session.authenticated;
    if (auth == null) {
      throw Exception('인증이 필요합니다.');
    }
    
    return await User.db.findFirstRow(
      session,
      where: (u) => u.userInfoId.equals(auth.userId),
    ) ?? throw Exception('사용자를 찾을 수 없습니다.');
  }
}
```

### 클라이언트 측

```dart
// gear_freak_flutter/lib/core/service/pod_service.dart
class PodService {
  static final PodService _instance = PodService._();
  static PodService get instance => _instance;
  
  late Client client;
  late SessionManager sessionManager;
  
  factory PodService.initialize({required String baseUrl}) {
    _instance.client = Client(
      baseUrl,
      authenticationKeyManager: FlutterAuthenticationKeyManager(),
    )..connectivityMonitor = FlutterConnectivityMonitor();
    
    _instance.sessionManager = SessionManager(
      caller: _instance.client.modules.auth,
    );
    
    return _instance;
  }
}

// gear_freak_flutter/lib/feature/auth/data/datasource/auth_remote_datasource.dart
class AuthRemoteDataSource {
  final PodService podService;
  
  Future<UserInfo> login({
    required String email,
    required String password,
  }) async {
    final authenticate = await podService.email.authenticate(
      email: email,
      password: password,
    );
    
    if (authenticate.success && authenticate.userInfo != null) {
      await podService.sessionManager.registerSignedInUser(
        authenticate.userInfo!,
        authenticate.keyId!,
        authenticate.key!,
      );
      return authenticate.userInfo!;
    }
    
    throw Exception('로그인 실패');
  }
}
```

---

## 참고 자료

- [Serverpod 인증 문서](https://docs.serverpod.dev/concepts/authentication)
- [Serverpod 모델 정의](https://docs.serverpod.dev/concepts/working-with-endpoints)
- kobic 프로젝트 참고:
  - `/Users/pyowonsik/Downloads/workspace/kobic/backend/kobic_server/lib/src/common/authenticated_mixin.dart`
  - `/Users/pyowonsik/Downloads/workspace/kobic/package/pod_service/lib/src/pod_service.dart`
  - `/Users/pyowonsik/Downloads/workspace/kobic/feature/common/auth/lib/src/data/repository/auth_repository.dart`


