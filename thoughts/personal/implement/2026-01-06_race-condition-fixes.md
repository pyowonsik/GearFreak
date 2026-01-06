# Race Condition Fixes - Implementation Log

**날짜**: 2026-01-06
**작업자**: Claude Code (Sonnet 4.5)
**관련 Plan**: `2026-01-06_race-condition-fix-plan.md`
**작업 시간**: ~20분

---

## 작업 개요

FCM Service의 `initialize()` 메서드가 여러 로그인 메서드에서 동시에 호출될 수 있는 경쟁 조건(Race Condition)을 수정했습니다. 초기화 가드 패턴을 적용하여 중복 초기화를 방지하고, 동시 호출 시 첫 번째 초기화가 완료될 때까지 대기하도록 개선했습니다.

---

## 수정 내역

### FCM Service (fcm_service.dart)

**파일**: `lib/shared/service/fcm_service.dart`

#### 변경사항:

1. **초기화 가드 필드 추가** (Line 25-28)
   ```dart
   // 초기화 가드 (경쟁 조건 방지)
   bool _isInitializing = false;
   bool _isInitialized = false;
   Completer<void>? _initCompleter;
   ```

2. **initialize() 메서드 수정** (Line 39-122)

   **Before**:
   ```dart
   Future<void> initialize() async {
     try {
       debugPrint('📱 FCM initialization started...');

       // 기존 구독 취소
       unawaited(_foregroundMessageSubscription?.cancel());
       unawaited(_tokenRefreshSubscription?.cancel());

       // 권한 요청 및 토큰 등록
       // ...
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

       // 기존 구독 취소
       unawaited(_foregroundMessageSubscription?.cancel());
       unawaited(_tokenRefreshSubscription?.cancel());

       // 권한 요청 및 토큰 등록
       // ... 기존 로직 유지

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
   ```

   **개선 포인트**:
   - `_isInitialized` 플래그로 이미 초기화된 경우 즉시 반환
   - `_isInitializing` 플래그와 `Completer`로 동시 호출 시 첫 번째 초기화 완료까지 대기
   - 초기화 완료/실패를 명시적으로 표시

3. **deleteToken() 메서드 수정** (Line 157-175)
   - 로그아웃 시 재초기화 허용을 위해 `_isInitialized = false` 추가

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

       // 재초기화 허용 (재로그인 시 다시 initialize 가능)
       _isInitialized = false;  // ✨ 추가
     }
   }
   ```

4. **dispose() 메서드 수정** (Line 177-189)
   - 초기화 상태 리셋 추가

   ```dart
   void dispose() {
     debugPrint('🗑️ [FcmService] Disposing...');
     _foregroundMessageSubscription?.cancel();
     _tokenRefreshSubscription?.cancel();
     onMessageReceived = null;
     onNotificationReceived = null;

     // 초기화 상태 리셋 (✨ 추가)
     _isInitialized = false;
     _isInitializing = false;
     _initCompleter = null;
   }
   ```

#### 영향:
- 동시 로그인 시도 시 중복 초기화 방지
- 권한 요청 중복 방지
- FCM 토큰 중복 등록 방지
- 리스너 중복 등록 방지
- 재로그인 시 정상적으로 재초기화 가능

---

## 테스트 수행

### 컴파일 확인
```bash
flutter analyze
```
**결과**: No issues found ✅

---

## 동작 시나리오

### Scenario 1: 정상 초기화
```
User: 로그인 버튼 클릭
→ LoginUseCase: FCM.initialize() 호출
→ FCM: "📱 FCM initialization started..."
→ FCM: 권한 요청, 토큰 등록, 리스너 등록
→ FCM: "✅ FCM initialization completed"
→ _isInitialized = true
```

### Scenario 2: 중복 초기화 시도 (이미 초기화됨)
```
User: 로그인 (이미 로그인 상태)
→ LoginUseCase: FCM.initialize() 호출
→ FCM: _isInitialized == true
→ FCM: "✅ FCM already initialized, skipping..."
→ 즉시 반환 (실제 초기화 안 함)
```

### Scenario 3: 동시 초기화 시도 (초기화 진행 중)
```
Time 0s: User clicks login
→ LoginUseCase: FCM.initialize() 호출 (Call #1)
→ FCM: _isInitializing = true, Completer 생성
→ FCM: "📱 FCM initialization started..."

Time 1s: (권한 요청 중)

Time 2s: User clicks login again (accidentally)
→ LoginUseCase: FCM.initialize() 호출 (Call #2)
→ FCM: _isInitializing == true
→ FCM: "⏳ FCM initialization in progress, waiting..."
→ Call #2는 Call #1의 Completer.future를 반환받아 대기

Time 3s: Call #1 초기화 완료
→ FCM: "✅ FCM initialization completed"
→ Completer.complete() 호출
→ Call #2도 자동으로 완료됨

Result: 실제 초기화는 1번만 수행됨 ✅
```

### Scenario 4: 로그아웃 후 재로그인
```
User: 로그아웃
→ AuthNotifier: FCM.deleteToken() 호출
→ FCM: _isInitialized = false (재초기화 허용)

User: 재로그인
→ LoginUseCase: FCM.initialize() 호출
→ FCM: _isInitialized == false → 정상 초기화 진행
→ FCM: "📱 FCM initialization started..."
→ 정상적으로 재초기화 완료
```

---

## 수정 전/후 비교

### Before (문제 상황)
```dart
// 동시에 2번 호출되는 경우
FCM.initialize() → 권한 요청 #1, 토큰 등록 #1, 리스너 등록 #1
FCM.initialize() → 권한 요청 #2, 토큰 등록 #2, 리스너 등록 #2

문제점:
- 권한 요청 다이얼로그가 2번 뜸
- 서버에 토큰이 2번 전송됨
- 리스너가 중복 등록됨 (메모리 누수는 해결했지만 비효율적)
```

### After (수정 후)
```dart
// 동시에 2번 호출되는 경우
FCM.initialize() #1 → 실제 초기화 진행
FCM.initialize() #2 → #1 완료까지 대기 (실제 초기화 안 함)

개선점:
- 권한 요청 1번만
- 서버에 토큰 1번만 전송
- 리스너 1세트만 등록
- 예측 가능한 동작
```

---

## 예상 효과

### 성능 개선
- 불필요한 권한 요청 방지
- 서버 API 호출 중복 방지 (네트워크 트래픽 감소)
- 리스너 중복 등록 방지 (메모리 효율)

### 안정성 향상
- 경쟁 조건으로 인한 예측 불가능한 동작 방지
- 초기화 상태 명확화 (`_isInitialized`, `_isInitializing`)
- 재로그인 시 정상적인 재초기화 보장

### 사용자 경험
- 빠른 로그인 응답 (중복 초기화 스킵)
- 안정적인 알림 수신
- 예상치 못한 권한 요청 다이얼로그 방지

---

## 추가 작업 필요 사항

### 즉시 작업
없음 - Critical 경쟁 조건 수정 완료 ✅

### 향후 고려사항
1. **재초기화 메서드**: 필요 시 명시적인 `reinitialize()` 메서드 추가
   ```dart
   Future<void> reinitialize() async {
     _isInitialized = false;
     return initialize();
   }
   ```

2. **타임아웃**: 초기화가 너무 오래 걸릴 경우 타임아웃 추가
   ```dart
   return _initCompleter?.future.timeout(
     const Duration(seconds: 30),
     onTimeout: () {
       debugPrint('⚠️ FCM initialization timeout');
       throw TimeoutException('FCM initialization timeout');
     },
   );
   ```

3. **통합 테스트**: 동시 초기화 방지를 검증하는 integration test 작성

---

## 관련 파일

### 수정된 파일
- [x] `lib/shared/service/fcm_service.dart`

### 영향받는 파일 (FCM.initialize() 호출)
- `lib/feature/auth/presentation/provider/auth_notifier.dart`
- `lib/feature/auth/domain/usecase/login_usecase.dart`
- `lib/feature/auth/domain/usecase/login_with_kakao_usecase.dart`
- `lib/feature/auth/domain/usecase/login_with_naver_usecase.dart`
- `lib/feature/auth/domain/usecase/login_with_google_usecase.dart`
- `lib/feature/auth/domain/usecase/login_with_apple_usecase.dart`
- `lib/feature/auth/domain/usecase/signup_usecase.dart`

**참고**: 이 파일들은 수정할 필요 없음 (FCM Service 내부 구현만 변경)

---

## 체크리스트

수정 작업:
- [x] 초기화 가드 필드 추가
- [x] initialize() 메서드 수정
- [x] deleteToken() 메서드 수정
- [x] dispose() 메서드 수정
- [x] 컴파일 에러 확인

후속 작업:
- [ ] 실제 기기에서 기능 테스트
- [ ] 동시 로그인 시도 테스트
- [ ] 로그아웃/재로그인 반복 테스트
- [ ] 커밋 및 PR 생성

---

## 커밋 메시지 (제안)

```
fix: prevent race condition in FCM initialization

- Add initialization guard with _isInitializing flag
- Add _isInitialized flag to prevent duplicate initialization
- Use Completer to queue concurrent initialize() calls
- Reset initialization state in deleteToken() for re-login
- Reset initialization state in dispose() for cleanup

This fixes a Critical race condition where FCM.initialize()
could be called multiple times concurrently from different
login methods, causing duplicate permission requests, token
registrations, and listener setups.

Closes #[ISSUE_NUMBER]
```

---

## 결론

FCM Service의 경쟁 조건 문제를 성공적으로 수정했습니다:
- ✅ 초기화 가드 패턴 적용
- ✅ 중복 초기화 방지
- ✅ 동시 호출 시 대기 메커니즘
- ✅ 재로그인 시 정상 재초기화 지원
- ✅ 컴파일 에러 없음

**다음 단계**: 실제 기기에서 동시 로그인 시나리오 테스트 후 커밋
