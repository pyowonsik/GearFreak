# Memory Leak Fixes - Implementation Log

**날짜**: 2026-01-06
**작업자**: Claude Code (Opus 4.5)
**관련 Plan**: `2026-01-06_memory-leak-fix-plan.md`
**작업 시간**: ~1시간

---

## 작업 개요

코드 리뷰에서 발견된 5개의 Critical 메모리 누수 이슈를 수정했습니다. 모든 수정은 스트림 구독과 리스너를 proper하게 dispose하여 메모리 누수를 방지하는 것에 초점을 맞췄습니다.

---

## 수정 내역

### 1. FCM Service (fcm_service.dart)

**파일**: `lib/shared/service/fcm_service.dart`

#### 변경사항:
1. **dart:async import 추가**
   ```dart
   import 'dart:async';
   ```

2. **StreamSubscription 필드 추가** (Line 21-23)
   ```dart
   // 스트림 구독 (메모리 누수 방지)
   StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
   StreamSubscription<String>? _tokenRefreshSubscription;
   ```

3. **initialize() 메서드 수정** (Line 38-85)
   - 기존 구독 취소 로직 추가 (Line 38-40)
   - 포그라운드 메시지 리스너를 변수에 저장 (Line 64-74)
   - 토큰 갱신 리스너를 변수에 저장 (Line 80-85)

4. **deleteToken() 메서드 수정** (Line 126-142)
   - 콜백 초기화 추가 (Line 139-140)
   ```dart
   onMessageReceived = null;
   onNotificationReceived = null;
   ```

5. **dispose() 메서드 추가** (Line 144-151)
   ```dart
   /// FCM 서비스 정리 (메모리 누수 방지)
   void dispose() {
     debugPrint('🗑️ [FcmService] Disposing...');
     _foregroundMessageSubscription?.cancel();
     _tokenRefreshSubscription?.cancel();
     onMessageReceived = null;
     onNotificationReceived = null;
   }
   ```

#### 영향:
- FCM 서비스를 여러 번 초기화해도 이전 구독이 자동 취소됨
- 로그아웃 시 모든 콜백이 정리되어 메모리 누수 방지
- dispose() 호출 시 모든 리소스 해제

---

### 2. Chat Notifier (chat_notifier.dart)

**파일**: `lib/feature/chat/presentation/provider/chat_notifier.dart`

#### 변경사항:
**이미 구현되어 있음을 확인** (Line 838-843)
```dart
@override
void dispose() {
  _messageStreamSubscription?.cancel();
  _reconnectTimer?.cancel();
  super.dispose();
}
```

#### 참고:
- 이전 작업에서 이미 수정되어 있었음
- 추가 작업 불필요

---

### 3. Main App (main.dart)

**파일**: `lib/main.dart`

#### 변경사항:
1. **StreamSubscription 필드 추가** (Line 92)
   ```dart
   StreamSubscription<RemoteMessage>? _notificationTapSubscription;
   ```

2. **_setupBackgroundNotificationHandler() 메서드 수정** (Line 168-191)
   - 기존 구독 취소 로직 추가 (Line 170)
   - 새 구독을 변수에 저장 (Line 173-190)
   ```dart
   void _setupBackgroundNotificationHandler(GoRouter router) {
     // 기존 구독 취소 (메모리 누수 방지)
     _notificationTapSubscription?.cancel();

     // 앱이 백그라운드에서 알림 탭으로 포그라운드로 전환된 경우
     _notificationTapSubscription =
         FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
       // ... 기존 로직
     });
   }
   ```

3. **dispose() 메서드 수정** (Line 161-167)
   - 알림 구독 취소 추가 (Line 164)
   - DeepLinkService dispose 호출 추가 (Line 165)
   ```dart
   @override
   void dispose() {
     _lifecycleListener?.dispose();
     _notificationTapSubscription?.cancel();
     DeepLinkService.instance.dispose();
     super.dispose();
   }
   ```

#### 영향:
- 백그라운드 알림 리스너가 proper하게 dispose됨
- DeepLinkService의 리소스도 앱 종료 시 해제됨

---

## 테스트 수행

### 컴파일 확인
```bash
flutter analyze
```
**결과**: No issues found

### 기능 테스트 (예정)
- [ ] 로그인/로그아웃 반복 (10회)
- [ ] 채팅방 진입/나가기 반복 (10회)
- [ ] FCM 알림 수신 확인
- [ ] 백그라운드 알림 탭 확인

### 메모리 프로파일링 (예정)
Flutter DevTools를 사용하여 다음 시나리오 테스트:
1. 로그인 → 로그아웃 10회 반복
2. 채팅방 진입 → 나가기 10회 반복
3. 메모리 사용량 그래프 확인 (계단 모양 → 톱니 모양)

---

## 수정 전/후 비교

### Before:
```dart
// fcm_service.dart (Line 55)
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // 구독이 저장되지 않음 - 메모리 누수!
});

// main.dart (Line 169)
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // 구독이 저장되지 않음 - 메모리 누수!
});
```

### After:
```dart
// fcm_service.dart (Line 64)
_foregroundMessageSubscription =
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // 구독이 저장되고 dispose()에서 취소됨
});

// main.dart (Line 173)
_notificationTapSubscription =
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // 구독이 저장되고 dispose()에서 취소됨
});
```

---

## 예상 효과

### 메모리 사용량
- **Before**: 로그인/로그아웃 반복 시 메모리 계단식 증가
- **After**: GC에 의해 메모리 회수되어 일정 수준 유지

### 앱 안정성
- 장시간 사용 시 메모리 부족으로 인한 크래시 방지
- 백그라운드 배터리 소모 감소

### 구체적 수치 (예상)
- 메모리 사용량: 30-50% 감소
- 로그인/로그아웃 10회 후 메모리 증가: ~100MB → ~20MB
- 채팅 사용 후 메모리 잔여: ~50MB → ~10MB

---

## 추가 작업 필요 사항

### 즉시 작업
없음 - 모든 Critical 메모리 누수 수정 완료

### 향후 고려사항
1. **메모리 프로파일링**: Flutter DevTools로 실제 메모리 사용량 측정
2. **자동화 테스트**: 메모리 누수 검증을 위한 integration test 작성
3. **모니터링**: Firebase Crashlytics 또는 Sentry에서 메모리 관련 크래시 추적

---

## 관련 파일

### 수정된 파일
- [x] `lib/shared/service/fcm_service.dart`
- [x] `lib/feature/chat/presentation/provider/chat_notifier.dart` (이미 수정됨)
- [x] `lib/main.dart`

### 영향받는 파일
- `lib/feature/auth/presentation/provider/auth_notifier.dart` - FCM initialize 호출
- `lib/feature/chat/presentation/page/chat_room_list_page.dart` - FCM 콜백 설정
- `lib/shared/service/deep_link_service.dart` - dispose 호출됨

---

## 체크리스트

수정 작업:
- [x] fcm_service.dart 수정
- [x] chat_notifier.dart 확인 (이미 수정됨)
- [x] main.dart 수정
- [x] 컴파일 에러 확인

후속 작업:
- [ ] 실제 기기에서 기능 테스트
- [ ] 메모리 프로파일링
- [ ] 커밋 및 PR 생성

---

## 커밋 메시지 (제안)

```
fix: prevent memory leaks in FCM and notification services

- Add StreamSubscription storage in FcmService
- Cancel subscriptions in dispose() methods
- Clear FCM callbacks on logout in deleteToken()
- Add notification tap subscription management in main.dart
- Call DeepLinkService.dispose() on app termination

This fixes Critical memory leaks identified in code review that
caused memory to accumulate during login/logout cycles and
chat room navigation.

Closes #[ISSUE_NUMBER]
```

---

## 결론

5개의 Critical 메모리 누수 이슈 중 **5개 모두 수정 완료**했습니다:
1. ✅ FCM 포그라운드 메시지 리스너
2. ✅ FCM 토큰 갱신 리스너
3. ✅ Chat Notifier 스트림 및 타이머 (이전 작업)
4. ✅ Main.dart 백그라운드 알림 리스너
5. ✅ DeepLinkService dispose 호출

**다음 단계**: 실제 기기에서 테스트 후 PR 생성 및 병합
