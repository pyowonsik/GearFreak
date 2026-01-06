# Memory Leak Fix Plan

**작성일**: 2026-01-06
**목적**: Critical 메모리 누수 이슈 수정
**예상 소요 시간**: 2-3시간

---

## 배경

코드 리뷰 결과, 5개의 Critical 메모리 누수 이슈가 발견되었습니다. 이들은 모두 스트림 구독, 리스너, 타이머가 dispose/logout 시 정리되지 않아 메모리가 계속 누적되는 문제입니다.

---

## 수정할 파일 목록

### 1. `lib/shared/service/fcm_service.dart`
**문제점**:
- Line 55: `FirebaseMessaging.onMessage.listen()` - 구독 저장 안 됨
- Line 70: `_messaging.onTokenRefresh.listen()` - 구독 저장 안 됨
- Line 116-129: `deleteToken()` - 콜백 미정리

**수정 내용**:
1. `StreamSubscription` 필드 추가
2. `initialize()`에서 기존 구독 취소 후 새 구독 저장
3. `dispose()` 메서드 추가
4. `deleteToken()`에서 콜백 정리

---

### 2. `lib/feature/chat/presentation/provider/chat_notifier.dart`
**문제점**:
- Line 93: `StreamSubscription<pod.ChatMessageResponseDto>? _messageStreamSubscription` - 선언은 있으나 dispose 미구현
- Line 839-842: Timer도 dispose 미구현

**수정 내용**:
1. `dispose()` 메서드 추가 (StateNotifier override)
2. 스트림 구독 취소
3. 재연결 타이머 취소

---

### 3. `lib/main.dart`
**문제점**:
- Line 169: `FirebaseMessaging.onMessageOpenedApp.listen()` - 구독 저장 안 됨
- Line 138-142: `AppLifecycleListener` dispose 있으나 notification subscription은 없음

**수정 내용**:
1. `StreamSubscription` 필드 추가
2. State의 `dispose()`에서 구독 취소

---

### 4. `lib/shared/service/fcm_service.dart` (콜백 정리)
**문제점**:
- Line 20-24: `onMessageReceived`, `onNotificationReceived` 콜백이 로그아웃 후에도 남아있음

**수정 내용**:
1. `deleteToken()` 메서드에서 콜백을 `null`로 설정

---

### 5. `lib/main.dart` (DeepLinkService dispose)
**문제점**:
- DeepLinkService가 초기화되지만 dispose가 호출되지 않음

**수정 내용**:
1. `_MyAppState.dispose()`에서 `DeepLinkService.instance.dispose()` 호출

---

## 수정 계획 단계별

### Step 1: FCM Service 수정
**파일**: `lib/shared/service/fcm_service.dart`

```dart
// 추가할 필드
StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
StreamSubscription<String>? _tokenRefreshSubscription;

// initialize() 메서드 수정
Future<void> initialize() async {
  // 기존 구독 취소
  _foregroundMessageSubscription?.cancel();
  _tokenRefreshSubscription?.cancel();

  // 권한 요청
  // ...

  // 토큰 가져오기
  // ...

  // 포그라운드 메시지 리스너 (구독 저장)
  _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(...);

  // 토큰 갱신 리스너 (구독 저장)
  _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(...);
}

// dispose() 메서드 추가
void dispose() {
  _foregroundMessageSubscription?.cancel();
  _tokenRefreshSubscription?.cancel();
  onMessageReceived = null;
  onNotificationReceived = null;
}

// deleteToken() 메서드 수정
Future<void> deleteToken() async {
  try {
    if (_currentToken != null) {
      final client = PodService.instance.client;
      await client.fcm.deleteFcmToken(_currentToken!);
    }
  } catch (e) {
    debugPrint('❌ Failed to delete FCM token: $e');
  } finally {
    _currentToken = null;
    // 콜백 정리
    onMessageReceived = null;
    onNotificationReceived = null;
  }
}
```

---

### Step 2: Chat Notifier 수정
**파일**: `lib/feature/chat/presentation/provider/chat_notifier.dart`

```dart
// dispose() 메서드 추가 (클래스 끝에)
@override
void dispose() {
  debugPrint('🗑️ [ChatNotifier] Disposing...');
  _messageStreamSubscription?.cancel();
  _reconnectTimer?.cancel();
  super.dispose();
}
```

위치: 클래스의 마지막 부분 (현재 line 842 이후)

---

### Step 3: main.dart 수정
**파일**: `lib/main.dart`

```dart
// _MyAppState 클래스에 필드 추가 (line 138 근처)
StreamSubscription<RemoteMessage>? _notificationTapSubscription;

// _setupBackgroundNotificationHandler 메서드 수정 (line 169)
void _setupBackgroundNotificationHandler(GoRouter router) {
  // 기존 구독 취소
  _notificationTapSubscription?.cancel();

  // 새 구독 저장
  _notificationTapSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {
      // 기존 로직
    },
  );
}

// dispose() 메서드 수정 (line 196-201)
@override
void dispose() {
  _lifecycleListener?.dispose();
  _notificationTapSubscription?.cancel();  // 추가
  DeepLinkService.instance.dispose();       // 추가
  super.dispose();
}
```

---

## 테스트 계획

### 메모리 누수 검증
1. Flutter DevTools → Performance → Memory 탭 열기
2. 다음 시나리오 실행:
   - 로그인 → 로그아웃 10회 반복
   - 채팅방 진입 → 나가기 10회 반복
   - 푸시 알림 탭하여 앱 열기 10회 반복
3. 메모리 사용량 그래프 확인
   - 기대: 톱니 모양 (사용 → GC → 사용 → GC)
   - 문제: 계단 모양 (계속 증가)

### 기능 테스트
1. FCM 알림 수신 확인
2. 채팅 메시지 송수신 확인
3. 백그라운드 알림 탭 시 딥링크 작동 확인
4. 로그아웃 후 재로그인 시 정상 작동 확인

---

## 예상 영향 범위

### 긍정적 효과
- 장시간 사용 시 메모리 사용량 30-50% 감소 예상
- 앱 크래시 빈도 감소
- 백그라운드에서 배터리 소모 감소

### 잠재적 리스크
- FCM 리스너 재등록 로직 변경으로 인한 알림 수신 이슈 가능성
  - 완화: 철저한 테스트
- dispose 타이밍 이슈로 일부 콜백 누락 가능성
  - 완화: 로그 추가하여 모니터링

---

## 체크리스트

수정 전:
- [ ] 현재 브랜치 확인 (main에서 작업 중인지)
- [ ] 수정 전 상태 커밋 (백업용)

수정 중:
- [ ] fcm_service.dart 수정
- [ ] chat_notifier.dart 수정
- [ ] main.dart 수정
- [ ] 각 파일 수정 후 컴파일 에러 확인

수정 후:
- [ ] Flutter analyze 실행
- [ ] 앱 실행하여 기본 기능 확인
- [ ] 메모리 프로파일링 테스트
- [ ] 커밋 (메시지: "fix: memory leaks in FCM and Chat services")

---

## 참고 자료

- [Flutter Memory Management](https://flutter.dev/docs/testing/best-practices#avoid-memory-leaks)
- [Riverpod Lifecycle](https://riverpod.dev/docs/concepts/provider_lifecycles)
- [Firebase Messaging Listeners](https://firebase.flutter.dev/docs/messaging/usage)
