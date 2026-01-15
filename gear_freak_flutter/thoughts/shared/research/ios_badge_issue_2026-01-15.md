# iOS 앱 아이콘 배지 문제 분석

**날짜**: 2026-01-15
**분석 대상**: 앱 설치 후 알림 배지가 1로 표시되는 문제

## 1. 문제 현상

- 앱을 다운로드/설치 후 iOS 앱 아이콘에 알림 배지 `1`이 표시됨
- 실제 로그인해서 확인하면 알림이 없음 (읽지 않은 알림 0개)

## 2. 원인 분석

### 서버 FCM 코드 (`gear_freak_server/lib/src/common/fcm/service/fcm_service.dart`)

```dart
// 라인 156-170
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
      'badge': 1,  // ⚠️ 문제: 항상 1로 하드코딩
    },
  },
};
```

### 문제점

1. **서버에서 FCM 알림 전송 시 `badge: 1`을 항상 하드코딩**
   - 모든 푸시 알림이 iOS 배지를 `1`로 설정
   - 실제 읽지 않은 알림 개수와 무관하게 항상 `1`

2. **앱에서 배지 리셋 로직 없음**
   - `flutter_app_badger` 같은 패키지 미사용
   - 앱이 열릴 때 배지를 `0`으로 리셋하는 코드 없음

3. **iOS 배지 동작 특성**
   - iOS는 앱이 명시적으로 배지를 변경하지 않는 한 이전 값 유지
   - 한 번이라도 알림을 받으면 배지가 계속 유지됨

## 3. 해결 방법

### 방법 1: Flutter 앱에서 배지 리셋 (권장)

1. `flutter_app_badger` 패키지 추가:
```yaml
# pubspec.yaml
dependencies:
  flutter_app_badger: ^1.5.0
```

2. 앱이 포그라운드로 올 때 배지 리셋:
```dart
// main.dart 또는 적절한 위치
import 'package:flutter_app_badger/flutter_app_badger.dart';

// 앱 라이프사이클에서
_lifecycleListener = AppLifecycleListener(
  onStateChange: (AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 배지 리셋
      FlutterAppBadger.removeBadge();
      // 또는 실제 읽지 않은 알림 개수로 업데이트
      // FlutterAppBadger.updateBadgeCount(unreadCount);
    }
  },
);
```

3. 로그인 후 배지 리셋:
```dart
// 로그인 성공 후
FlutterAppBadger.removeBadge();
```

### 방법 2: 서버에서 동적 배지 값 설정

```dart
// gear_freak_server/lib/src/common/fcm/service/fcm_service.dart

static Future<bool> sendNotification({
  required Session session,
  required String fcmToken,
  required String title,
  required String body,
  Map<String, dynamic>? data,
  bool includeNotification = true,
  int? badge,  // 배지 값을 파라미터로 받음
}) async {
  // ...

  message['message']!['apns'] = {
    'payload': {
      'aps': {
        'alert': { ... },
        'sound': 'default',
        'badge': badge ?? 1,  // 전달받은 값 사용 (없으면 1)
      },
    },
  };
}
```

알림 전송 시 실제 읽지 않은 알림 개수를 조회하여 전달:
```dart
// 알림 전송 시
final unreadCount = await NotificationService.getUnreadCount(session, userId);
await FcmService.sendNotification(
  session: session,
  fcmToken: token,
  title: '새 알림',
  body: '...',
  badge: unreadCount,
);
```

## 4. 권장 사항

1. **단기 해결 (Flutter 앱)**:
   - `flutter_app_badger` 패키지 추가
   - 앱 포그라운드 진입 시 `FlutterAppBadger.removeBadge()` 호출

2. **장기 해결 (서버 + 앱)**:
   - 서버에서 알림 전송 시 실제 읽지 않은 알림 개수를 badge로 전달
   - 앱에서 알림 읽음 처리 시 서버에 badge 업데이트 요청
   - Silent push를 통해 배지만 업데이트하는 메커니즘 추가

## 5. 관련 파일

- **서버**: `gear_freak_server/lib/src/common/fcm/service/fcm_service.dart:167`
- **Flutter 앱**: `gear_freak_flutter/lib/main.dart` (라이프사이클 리스너)
- **Flutter 앱**: `gear_freak_flutter/lib/shared/service/fcm_service.dart`

## 6. 참고

- iOS APNs badge 문서: https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification
- flutter_app_badger: https://pub.dev/packages/flutter_app_badger
