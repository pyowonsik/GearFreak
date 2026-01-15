# iOS 앱 아이콘 배지 동적 설정 구현 계획

**날짜**: 2026-01-15
**작성자**: Claude
**관련 연구 문서**: `thoughts/shared/research/ios_badge_issue_2026-01-15.md`

## 1. 요구사항

### 기능 개요
서버에서 FCM 알림 전송 시 iOS 앱 아이콘 배지를 실제 읽지 않은 알림/채팅 개수로 동적 설정

### 현재 문제점
- 서버에서 FCM 알림 전송 시 `badge: 1`을 항상 하드코딩
- 앱 설치 후 배지가 1로 고정되어 실제 알림 개수와 불일치
- 앱에서 배지를 리셋하는 코드 없음

### 목표
- 서버에서 알림 전송 시 실제 읽지 않은 개수를 badge로 전달
- 앱에서 알림 확인/읽음 처리 시 배지가 정확하게 반영되도록 함

### 성공 기준
- [ ] 채팅 알림 전송 시 읽지 않은 채팅 + 알림 총 개수가 badge로 설정됨
- [ ] 리뷰 알림 전송 시 읽지 않은 채팅 + 알림 총 개수가 badge로 설정됨
- [ ] 앱 포그라운드 진입 시 배지가 실제 읽지 않은 개수와 일치함
- [ ] 로그인 후 배지가 올바르게 표시됨

## 2. 기술적 접근

### 아키텍처 선택
서버와 클라이언트 양쪽 모두 수정 필요

### 사용할 패키지
- **Flutter 앱**: `flutter_app_badger: ^1.5.0` (배지 리셋/업데이트용)
- **서버**: 기존 패키지 사용

### 변경 파일 목록

**서버 (gear_freak_server)**:
```
lib/src/common/fcm/service/fcm_service.dart          # badge 파라미터 추가
lib/src/feature/chat/service/chat_notification_service.dart  # badge 계산 및 전달
lib/src/feature/review/service/review_service.dart   # badge 계산 및 전달
```

**Flutter 앱 (gear_freak_flutter)**:
```
pubspec.yaml                                          # flutter_app_badger 추가
lib/main.dart                                         # 앱 포그라운드 시 배지 리셋
lib/feature/auth/presentation/provider/auth_notifier.dart  # 로그인 시 배지 리셋
```

## 3. 구현 단계

### Phase 1: 서버 - FcmService에 badge 파라미터 추가
**목표**: FcmService가 동적 badge 값을 받을 수 있도록 수정

**작업 목록**:
- [ ] `FcmService.sendNotification()`에 `int? badge` 파라미터 추가
- [ ] `FcmService.sendNotifications()`에 `int? badge` 파라미터 추가
- [ ] APNs payload에서 하드코딩된 `'badge': 1`을 `'badge': badge`로 변경

**수정 코드** (`gear_freak_server/lib/src/common/fcm/service/fcm_service.dart`):

```dart
// sendNotification 함수 시그니처 변경
static Future<bool> sendNotification({
  required Session session,
  required String fcmToken,
  required String title,
  required String body,
  Map<String, dynamic>? data,
  bool includeNotification = true,
  int? badge,  // 추가: iOS 배지 값 (null이면 배지 변경 안 함)
}) async {
  // ...

  // APNs payload 변경 (라인 156-170)
  message['message']!['apns'] = {
    'headers': {
      'apns-priority': '10',
    },
    'payload': {
      'aps': {
        'alert': {
          'title': title,
          'body': body,
        },
        'sound': 'default',
        if (badge != null) 'badge': badge,  // 조건부 badge 설정
      },
    },
  };
}

// sendNotifications 함수 시그니처 변경
static Future<int> sendNotifications({
  required Session session,
  required List<String> fcmTokens,
  required String title,
  required String body,
  Map<String, dynamic>? data,
  bool includeNotification = true,
  int? badge,  // 추가
}) async {
  // ...
  final futures = fcmTokens.map((token) => sendNotification(
    session: session,
    fcmToken: token,
    title: title,
    body: body,
    data: data,
    includeNotification: includeNotification,
    badge: badge,  // 전달
  ));
}
```

**예상 영향**:
- 기존 호출부에서 badge 파라미터를 전달하지 않으면 배지가 변경되지 않음 (기존 동작과 다름)
- 모든 호출부에서 badge를 명시적으로 전달해야 함

**검증 방법**:
- [ ] 서버 빌드 성공 확인
- [ ] 기존 FCM 알림 전송 테스트

---

### Phase 2: 서버 - 채팅 알림에서 badge 계산 및 전달
**목표**: 채팅 메시지 알림 전송 시 수신자의 읽지 않은 총 개수를 badge로 전달

**작업 목록**:
- [ ] `ChatNotificationService.sendFcmNotification()`에서 수신자별 읽지 않은 개수 계산
- [ ] 읽지 않은 채팅 + 알림 개수 합산하여 badge로 전달

**수정 코드** (`gear_freak_server/lib/src/feature/chat/service/chat_notification_service.dart`):

```dart
// sendFcmNotification 함수 내부 수정

// 참여자별 FCM 토큰 조회 시 userId도 함께 가져와야 함
// 기존: tokensWithSettings = Map<userId, Map<token, isNotificationEnabled>>

// 6. FCM 알림 전송 (알림 설정에 따라 분기)
// 알림 활성화된 사용자에게는 notification 포함하여 전송
if (tokensWithNotification.isNotEmpty) {
  // 사용자별로 badge 계산 필요
  for (final entry in tokensWithSettings.entries) {
    final userId = entry.key;
    final tokenMap = entry.value;

    final enabledTokens = tokenMap.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (enabledTokens.isEmpty) continue;

    // 해당 사용자의 읽지 않은 총 개수 계산
    final unreadChatCount = await getTotalUnreadChatCount(session, userId);
    final unreadNotificationCount = await NotificationService.getUnreadCount(
      session: session,
      userId: userId,
    );
    final totalBadge = unreadChatCount + unreadNotificationCount;

    await FcmService.sendNotifications(
      session: session,
      fcmTokens: enabledTokens,
      title: title,
      body: body,
      data: data,
      includeNotification: true,
      badge: totalBadge,  // 동적 badge 전달
    );
  }
}
```

**주의사항**:
- 기존 병렬 전송 로직을 사용자별 순차 전송으로 변경 (badge가 사용자마다 다르기 때문)
- 성능 영향 최소화를 위해 badge 계산은 알림 활성화된 사용자만 대상으로 함

**예상 영향**:
- 채팅 알림 전송 시 약간의 지연 발생 가능 (badge 계산 때문)
- iOS 앱 아이콘 배지가 정확한 읽지 않은 개수로 표시됨

**검증 방법**:
- [ ] 채팅 메시지 전송 후 수신자 iOS 배지 확인
- [ ] 여러 알림이 있을 때 badge 값이 누적되는지 확인

---

### Phase 3: 서버 - 리뷰 알림에서 badge 계산 및 전달
**목표**: 리뷰 알림 전송 시 수신자의 읽지 않은 총 개수를 badge로 전달

**작업 목록**:
- [ ] `ReviewService._sendReviewNotification()`에서 수신자별 읽지 않은 개수 계산
- [ ] 읽지 않은 채팅 + 알림 개수 합산하여 badge로 전달

**수정 코드** (`gear_freak_server/lib/src/feature/review/service/review_service.dart`):

```dart
// _sendReviewNotification 함수 내부 수정 (라인 370 부근)

// 3.5. 읽지 않은 총 개수 계산 (badge용)
final unreadChatCount = await ChatNotificationService().getTotalUnreadChatCount(
  session,
  revieweeId,
);
final unreadNotificationCount = await NotificationService.getUnreadCount(
  session: session,
  userId: revieweeId,
);
// 현재 알림도 포함해야 하므로 +1
final totalBadge = unreadChatCount + unreadNotificationCount + 1;

// 4. FCM 알림 전송
await FcmService.sendNotifications(
  session: session,
  fcmTokens: fcmTokens,
  title: title,
  body: body,
  data: data,
  includeNotification: true,
  badge: totalBadge,  // 동적 badge 전달
);
```

**예상 영향**:
- 리뷰 알림 전송 시 약간의 지연 발생 가능 (badge 계산 때문)
- iOS 앱 아이콘 배지가 정확한 읽지 않은 개수로 표시됨

**검증 방법**:
- [ ] 리뷰 작성 후 리뷰 대상자 iOS 배지 확인
- [ ] 기존 알림이 있을 때 badge 값이 누적되는지 확인

---

### Phase 4: Flutter 앱 - flutter_app_badger 패키지 추가 및 배지 리셋
**목표**: 앱이 포그라운드로 올 때 및 로그인 시 배지를 정확한 값으로 업데이트

**작업 목록**:
- [ ] `pubspec.yaml`에 `flutter_app_badger: ^1.5.0` 추가
- [ ] `main.dart`에서 앱 포그라운드 진입 시 배지 리셋 또는 실제 개수로 업데이트
- [ ] 로그인 성공 시 배지 리셋

**수정 코드 1** (`gear_freak_flutter/pubspec.yaml`):
```yaml
dependencies:
  # ... 기존 의존성
  flutter_app_badger: ^1.5.0  # 추가
```

**수정 코드 2** (`gear_freak_flutter/lib/main.dart`):
```dart
import 'package:flutter_app_badger/flutter_app_badger.dart';

// _MyAppState 클래스 내부

// 앱 생명주기 리스너에서 배지 업데이트 추가
_lifecycleListener = AppLifecycleListener(
  onStateChange: (AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _refreshUnreadCount();
      if (!mounted) return;
      // ignore: unused_result
      ref.refresh(totalUnreadNotificationCountProvider);

      // iOS 배지 업데이트 (실제 읽지 않은 개수로)
      await _updateAppBadge();
    }
  },
);

// 배지 업데이트 메서드 추가
Future<void> _updateAppBadge() async {
  try {
    // 읽지 않은 채팅 + 알림 개수 조회
    final chatCountAsync = ref.read(totalUnreadChatCountProvider);
    final notificationCountAsync = ref.read(totalUnreadNotificationCountProvider);

    final chatCount = chatCountAsync.value ?? 0;
    final notificationCount = notificationCountAsync.value ?? 0;
    final totalCount = chatCount + notificationCount;

    if (totalCount > 0) {
      await FlutterAppBadger.updateBadgeCount(totalCount);
    } else {
      await FlutterAppBadger.removeBadge();
    }
  } catch (e) {
    debugPrint('⚠️ 배지 업데이트 실패: $e');
  }
}
```

**수정 코드 3** (로그인 성공 시 - `auth_notifier.dart` 또는 관련 위치):
```dart
// 로그인 성공 후
await FlutterAppBadger.removeBadge();  // 초기 배지 리셋
```

**예상 영향**:
- 앱이 포그라운드로 올 때마다 배지가 업데이트됨
- 로그인 직후 배지가 0으로 리셋됨 (아직 알림 조회 전)

**검증 방법**:
- [ ] 앱 설치 후 배지가 0인지 확인
- [ ] 알림 받은 후 앱 열면 배지가 실제 읽지 않은 개수와 일치하는지 확인
- [ ] 알림 읽음 처리 후 앱 재진입 시 배지가 감소하는지 확인

---

### Phase 5: 통합 테스트 및 검증
**목표**: 전체 시스템이 올바르게 동작하는지 확인

**테스트 시나리오**:

1. **신규 사용자 시나리오**:
   - [ ] 앱 설치 직후 배지 = 0
   - [ ] 로그인 후 배지 = 0 (알림 없는 경우)

2. **채팅 알림 시나리오**:
   - [ ] A가 B에게 메시지 전송 → B의 iOS 배지 = 1
   - [ ] A가 B에게 추가 메시지 전송 → B의 iOS 배지 = 2
   - [ ] B가 앱 열어서 채팅 읽음 → B의 iOS 배지 = 0

3. **리뷰 알림 시나리오**:
   - [ ] A가 B에게 리뷰 작성 → B의 iOS 배지 = 1
   - [ ] B가 앱 열어서 알림 확인 → B의 iOS 배지 = 0

4. **복합 시나리오**:
   - [ ] B가 읽지 않은 채팅 2개 + 알림 1개 있는 상태 → B의 iOS 배지 = 3
   - [ ] 추가 알림 수신 → B의 iOS 배지 = 4
   - [ ] B가 앱 열어서 일부만 읽음 → 배지가 남은 개수로 업데이트

**예상 영향**:
- iOS 앱 아이콘 배지가 항상 실제 읽지 않은 개수와 일치함

## 4. 리스크 및 대응

### 리스크 1: 성능 저하 (badge 계산 때문)
- **확률**: Medium
- **영향도**: Low
- **완화 방안**:
  - badge 계산은 알림 활성화된 사용자만 대상으로 함
  - 필요시 캐싱 도입 검토

### 리스크 2: 사용자별 badge가 다를 때 병렬 전송 불가
- **확률**: High
- **영향도**: Low
- **완화 방안**:
  - 사용자별 순차 전송으로 변경
  - 대부분의 채팅은 1:1이므로 성능 영향 미미

### 리스크 3: flutter_app_badger iOS 권한 문제
- **확률**: Low
- **영향도**: Medium
- **완화 방안**:
  - 알림 권한과 함께 배지 권한도 요청됨
  - 실패 시 로그만 남기고 무시

## 5. 전체 검증 계획

### 자동 테스트
- [ ] 서버 빌드 성공
- [ ] Flutter 앱 빌드 성공

### 수동 테스트
- [ ] iOS 디바이스에서 채팅 알림 수신 시 배지 확인
- [ ] iOS 디바이스에서 리뷰 알림 수신 시 배지 확인
- [ ] 앱 포그라운드 진입 시 배지 업데이트 확인
- [ ] 알림 읽음 처리 후 배지 감소 확인

### 성능 체크
- [ ] 알림 전송 지연 시간 측정 (badge 계산 추가 후)

## 6. 참고 사항

- iOS APNs badge 문서: https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification
- flutter_app_badger: https://pub.dev/packages/flutter_app_badger
- 연구 문서: `thoughts/shared/research/ios_badge_issue_2026-01-15.md`

## 7. 구현 순서 요약

1. **Phase 1**: 서버 FcmService에 badge 파라미터 추가
2. **Phase 2**: 채팅 알림에서 동적 badge 계산 및 전달
3. **Phase 3**: 리뷰 알림에서 동적 badge 계산 및 전달
4. **Phase 4**: Flutter 앱에서 flutter_app_badger로 배지 리셋/업데이트
5. **Phase 5**: 통합 테스트 및 검증
