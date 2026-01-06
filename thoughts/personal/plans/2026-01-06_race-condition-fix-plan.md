# Race Condition Fix Plan - FCM Service

**날짜**: 2026-01-06
**작업자**: Claude Code (Sonnet 4.5)
**관련 Plan**: `2026-01-06_code-review-improvement-plan.md` (Section 1.3)
**예상 소요 시간**: 30분

---

## 작업 개요

FCM Service의 `initialize()` 메서드가 여러 로그인 메서드에서 동시에 호출될 수 있어 경쟁 조건(Race Condition)이 발생할 가능성이 있습니다. 이를 방지하기 위해 초기화 가드 로직을 추가합니다.

---

## 문제 분석

### 현재 상황

**파일**: `lib/shared/service/fcm_service.dart`
**라인**: 34-92 (initialize 메서드)

FCM Service의 `initialize()`는 다음 상황에서 호출됩니다:

1. `LoginUseCase` - 이메일/비밀번호 로그인 후
2. `LoginWithKakaoUseCase` - 카카오 로그인 후
3. `LoginWithNaverUseCase` - 네이버 로그인 후
4. `LoginWithGoogleUseCase` - 구글 로그인 후
5. `LoginWithAppleUseCase` - 애플 로그인 후
6. `SignupUseCase` - 회원가입 후
7. 앱 재시작 시 자동 로그인

### 잠재적 문제

```dart
// 현재 코드
Future<void> initialize() async {
  try {
    debugPrint('📱 FCM initialization started...');

    // 구독 취소
    unawaited(_foregroundMessageSubscription?.cancel());
    unawaited(_tokenRefreshSubscription?.cancel());

    // 권한 요청
    final settings = await _messaging.requestPermission();

    // 토큰 가져오기
    final token = await _messaging.getToken();

    // 리스너 등록
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(...);
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(...);
  } catch (e) {
    debugPrint('⚠️ Failed to initialize FCM: $e');
  }
}
```

**문제점**:
1. 동시에 2번 호출되면 권한 요청이 2번 발생
2. 토큰 등록이 중복으로 서버에 전송될 수 있음
3. 리스너가 중복 등록될 수 있음 (메모리 누수는 해결했지만 여전히 비효율적)
4. 첫 번째 초기화가 완료되기 전에 두 번째 초기화가 시작되면 예측 불가능한 동작

### 재현 시나리오

```
시간 t0: 사용자가 로그인 버튼 클릭
시간 t1: LoginUseCase 실행 → FCM.initialize() 시작
시간 t2: initialize()가 권한 요청 중 (await)
시간 t3: 네트워크 지연으로 로그인 응답이 늦어짐
시간 t4: 사용자가 다시 로그인 버튼 클릭 (실수 또는 네트워크 응답 대기 중)
시간 t5: LoginUseCase 재실행 → FCM.initialize() 다시 시작
시간 t6: 두 개의 initialize()가 동시에 실행 중

결과: 리스너 중복 등록, 토큰 중복 전송, 예측 불가능한 상태
```

---

## 해결 방안

### 패턴: 초기화 가드 (Initialization Guard)

다음 3가지 요소를 사용하여 동시 호출을 방지합니다:

1. **`_isInitializing` 플래그**: 현재 초기화 중인지 확인
2. **`_initCompleter`**: 진행 중인 초기화의 Future를 반환
3. **`_isInitialized` 플래그**: 이미 초기화되었는지 확인 (선택적)

### 수정 코드 구조

```dart
class FcmService {
  // 기존 필드
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _currentToken;
  GoRouter? _router;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  // 초기화 가드 필드 추가
  bool _isInitializing = false;
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  Future<void> initialize() async {
    // 1. 이미 초기화 완료된 경우 즉시 반환
    if (_isInitialized) {
      debugPrint('✅ FCM already initialized, skipping...');
      return;
    }

    // 2. 초기화 진행 중인 경우 해당 Future 반환
    if (_isInitializing) {
      debugPrint('⏳ FCM initialization in progress, waiting...');
      return _initCompleter?.future;
    }

    // 3. 초기화 시작
    _isInitializing = true;
    _initCompleter = Completer<void>();

    try {
      debugPrint('📱 FCM initialization started...');

      // 기존 초기화 로직
      unawaited(_foregroundMessageSubscription?.cancel());
      unawaited(_tokenRefreshSubscription?.cancel());

      final settings = await _messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await _messaging.getToken();
        if (token != null) {
          _currentToken = token;
          await _registerTokenToServer(token);
        }

        _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(...);
        _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(...);
      }

      // 초기화 완료 표시
      _isInitialized = true;
      _initCompleter?.complete();
      debugPrint('✅ FCM initialization completed');

    } catch (e) {
      debugPrint('⚠️ Failed to initialize FCM: $e');
      _initCompleter?.completeError(e);
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  // 재초기화 메서드 (필요 시)
  Future<void> reinitialize() async {
    _isInitialized = false;
    return initialize();
  }

  // dispose 메서드 수정
  void dispose() {
    debugPrint('🗑️ [FcmService] Disposing...');
    _foregroundMessageSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    onMessageReceived = null;
    onNotificationReceived = null;

    // 초기화 상태 리셋
    _isInitialized = false;
    _isInitializing = false;
    _initCompleter = null;
  }
}
```

---

## 수정 상세

### 1. 필드 추가

**위치**: Line 21-23 이후

```dart
// 스트림 구독 (메모리 누수 방지)
StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
StreamSubscription<String>? _tokenRefreshSubscription;

// 초기화 가드 (경쟁 조건 방지)
bool _isInitializing = false;
bool _isInitialized = false;
Completer<void>? _initCompleter;
```

### 2. initialize() 메서드 수정

**위치**: Line 34-92

**Before**:
```dart
Future<void> initialize() async {
  try {
    debugPrint('📱 FCM initialization started...');
    // 기존 로직
  } catch (e) {
    debugPrint('⚠️ Failed to initialize FCM: $e');
  }
}
```

**After**:
```dart
Future<void> initialize() async {
  // 이미 초기화된 경우
  if (_isInitialized) {
    debugPrint('✅ FCM already initialized, skipping...');
    return;
  }

  // 초기화 진행 중인 경우
  if (_isInitializing) {
    debugPrint('⏳ FCM initialization in progress, waiting...');
    return _initCompleter?.future;
  }

  // 초기화 시작
  _isInitializing = true;
  _initCompleter = Completer<void>();

  try {
    debugPrint('📱 FCM initialization started...');

    // 기존 로직 그대로 유지
    unawaited(_foregroundMessageSubscription?.cancel());
    unawaited(_tokenRefreshSubscription?.cancel());

    final settings = await _messaging.requestPermission();
    // ... 나머지 로직

    _isInitialized = true;
    _initCompleter?.complete();
    debugPrint('✅ FCM initialization completed');

  } catch (e) {
    debugPrint('⚠️ Failed to initialize FCM: $e');
    _initCompleter?.completeError(e);
    rethrow;
  } finally {
    _isInitializing = false;
  }
}
```

### 3. dispose() 메서드 수정

**위치**: Line 144-151

```dart
void dispose() {
  debugPrint('🗑️ [FcmService] Disposing...');
  _foregroundMessageSubscription?.cancel();
  _tokenRefreshSubscription?.cancel();
  onMessageReceived = null;
  onNotificationReceived = null;

  // 초기화 상태 리셋 (추가)
  _isInitialized = false;
  _isInitializing = false;
  _initCompleter = null;
}
```

### 4. reinitialize() 메서드 추가 (선택적)

**위치**: dispose() 메서드 이전

```dart
/// FCM 서비스 재초기화 (로그아웃 후 재로그인 시 사용)
Future<void> reinitialize() async {
  debugPrint('🔄 [FcmService] Reinitializing...');
  _isInitialized = false;
  return initialize();
}
```

---

## 테스트 시나리오

### 1. 동시 호출 테스트

```dart
// 테스트 코드 (실제 앱에서는 필요 없음)
void testConcurrentInitialization() async {
  final fcm = FcmService.instance;

  // 동시에 3번 호출
  final future1 = fcm.initialize();
  final future2 = fcm.initialize();
  final future3 = fcm.initialize();

  await Future.wait([future1, future2, future3]);

  // 기대 결과: 실제로는 1번만 초기화됨
  // 로그:
  // 📱 FCM initialization started...
  // ⏳ FCM initialization in progress, waiting...
  // ⏳ FCM initialization in progress, waiting...
  // ✅ FCM initialization completed
}
```

### 2. 빠른 로그인/로그아웃 반복 테스트

```
1. 로그인 → FCM initialize 호출
2. 즉시 로그아웃 → FCM dispose 호출
3. 즉시 재로그인 → FCM initialize 재호출
4. 기대: 정상적으로 재초기화됨
```

### 3. 네트워크 지연 시뮬레이션

```
1. 로그인 시작 → FCM initialize 호출
2. getToken()에서 5초 지연
3. 2초 후 사용자가 다시 로그인 시도
4. 기대: 두 번째 initialize는 첫 번째가 완료될 때까지 대기
```

---

## 예상 효과

### Before (문제 상황)
```
User clicks login
  → LoginUseCase runs → FCM.initialize() starts
User clicks login again (accidentally)
  → LoginUseCase runs again → FCM.initialize() starts again

Result:
- 2 permission requests
- 2 token registrations to server
- Duplicate listeners
- Unpredictable state
```

### After (수정 후)
```
User clicks login
  → LoginUseCase runs → FCM.initialize() starts
User clicks login again (accidentally)
  → LoginUseCase runs again → FCM.initialize() waits for first one

Result:
- Only 1 permission request
- Only 1 token registration
- Only 1 set of listeners
- Predictable state
```

---

## 영향 범위

### 수정 파일
- `lib/shared/service/fcm_service.dart`

### 영향받는 파일 (호출하는 곳)
- `lib/feature/auth/presentation/provider/auth_notifier.dart` (로그인 후 호출)
- 모든 로그인 UseCase들:
  - `login_usecase.dart`
  - `login_with_kakao_usecase.dart`
  - `login_with_naver_usecase.dart`
  - `login_with_google_usecase.dart`
  - `login_with_apple_usecase.dart`
  - `signup_usecase.dart`

**중요**: 이 파일들은 수정할 필요 없음 (FCM Service 내부 구현만 변경)

---

## 추가 고려사항

### 1. deleteToken()과의 관계

로그아웃 시 `deleteToken()`이 호출되는데, 이후 재로그인 시 `initialize()`가 다시 호출되어야 합니다.

**권장**: `deleteToken()`에서 `_isInitialized = false`로 설정하여 재초기화 허용

```dart
Future<void> deleteToken() async {
  try {
    if (_currentToken != null) {
      final client = PodService.instance.client;
      await client.fcm.deleteFcmToken(_currentToken!);
      debugPrint('✅ FCM token deleted from server');
    }
  } catch (e) {
    debugPrint('❌ Failed to delete FCM token from server: $e');
  } finally {
    _currentToken = null;
    onMessageReceived = null;
    onNotificationReceived = null;

    // 재초기화 허용 (추가)
    _isInitialized = false;
  }
}
```

### 2. 시뮬레이터에서의 동작

iOS 시뮬레이터에서는 `getToken()`이 실패할 수 있습니다. 이 경우에도 초기화는 성공으로 간주해야 합니다.

**현재 코드**: 이미 try-catch로 처리되어 있음 ✅

---

## 체크리스트

수정 전:
- [ ] 현재 브랜치 확인
- [ ] fcm_service.dart 백업 (git status 확인)

수정 중:
- [ ] 초기화 가드 필드 추가
- [ ] initialize() 메서드 수정
- [ ] dispose() 메서드 수정
- [ ] deleteToken() 메서드 수정 (재초기화 허용)
- [ ] 컴파일 에러 확인

수정 후:
- [ ] flutter analyze 실행
- [ ] 앱 실행하여 로그인 테스트
- [ ] 로그인/로그아웃 반복 테스트 (5회)
- [ ] 빠른 중복 로그인 시도 테스트
- [ ] 로그 확인 (중복 초기화 방지 메시지)
- [ ] 커밋 및 implement 파일 작성

---

## 예상 소요 시간

- 코드 수정: 10분
- 테스트: 15분
- 문서 작성: 5분
- **총 30분**

---

## 참고 자료

- [Dart Completer](https://api.dart.dev/stable/dart-async/Completer-class.html)
- [Singleton Pattern Best Practices](https://dart.dev/guides/language/effective-dart/design#avoid-public-late-final-fields-without-initializers)
- [Race Condition Prevention](https://dart.dev/guides/language/concurrency)
