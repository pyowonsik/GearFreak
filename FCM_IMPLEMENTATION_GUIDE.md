# FCM 채팅 알림 구현 가이드

## 📋 목차

1. [개요](#개요)
2. [Phase 1: Firebase Console 설정](#phase-1-firebase-console-설정)
3. [Phase 2: 클라이언트 설정](#phase-2-클라이언트-설정)
4. [Phase 3: 서버 측 구현](#phase-3-서버-측-구현)
5. [Phase 4: 클라이언트 구현](#phase-4-클라이언트-구현)
6. [Phase 5: 테스트](#phase-5-테스트)
7. [트러블슈팅](#트러블슈팅)

---

## 개요

### FCM이란?
Firebase Cloud Messaging (FCM)은 Google에서 제공하는 무료 푸시 알림 서비스입니다.

### 과금 정보
- ✅ **FCM 자체는 완전 무료** (메시지 수 제한 없음)
- ✅ **Spark Plan (무료 플랜)으로 사용 가능**
- ⚠️ 다른 Firebase 서비스 (Cloud Functions, Storage 등) 사용 시에만 과금 가능

### 구현 목표
- 채팅 메시지 전송 시 수신자에게 푸시 알림 발송
- 포그라운드/백그라운드/앱 종료 상태 모두에서 알림 수신
- 알림 클릭 시 해당 채팅방으로 이동

---

## Phase 1: Firebase Console 설정

### 1-1. Android 앱 등록

1. **Firebase Console 접속**
   - https://console.firebase.google.com 접속
   - `gear-freak` 프로젝트 선택

2. **Android 앱 추가**
   - 프로젝트 개요 → "Android 앱 추가" 클릭
   - 패키지 이름 입력 (예: `com.example.gear_freak_flutter`)
     - 확인 방법: `gear_freak_flutter/android/app/build.gradle`에서 `applicationId` 확인
   - 앱 닉네임: `gear-freak-android` (선택사항)
   - 디버그 서명 인증서 SHA-1: 나중에 추가 가능

3. **google-services.json 다운로드**
   - 다운로드된 `google-services.json` 파일을 다음 위치에 복사:
   ```
   gear_freak_flutter/android/app/google-services.json
   ```

### 1-2. iOS 앱 등록 (선택사항)

1. **iOS 앱 추가**
   - 프로젝트 개요 → "iOS 앱 추가" 클릭
   - 번들 ID 입력 (예: `com.example.gearFreakFlutter`)
     - 확인 방법: `gear_freak_flutter/ios/Runner.xcodeproj`에서 확인
   - 앱 닉네임: `gear-freak-ios` (선택사항)

2. **GoogleService-Info.plist 다운로드**
   - 다운로드된 `GoogleService-Info.plist` 파일을 다음 위치에 복사:
   ```
   gear_freak_flutter/ios/Runner/GoogleService-Info.plist
   ```

3. **Xcode에서 파일 추가**
   - Xcode에서 `Runner.xcodeproj` 열기
   - `GoogleService-Info.plist`를 `Runner` 폴더로 드래그
   - "Copy items if needed" 체크

### 1-3. FCM 서버 키 발급

1. **프로젝트 설정 접속**
   - Firebase Console → 프로젝트 설정 (톱니바퀴 아이콘)

2. **클라우드 메시징 탭**
   - "클라우드 메시징" 탭 선택
   - "Cloud Messaging API (V1)" 활성화 (필요한 경우)

3. **서버 키 복사**
   - "서버 키" 또는 "Cloud Messaging API (V1)" 섹션에서 서버 키 복사
   - ⚠️ **보안**: 이 키는 서버 환경 변수에만 저장하고 Git에 커밋하지 않기

---

## Phase 2: 클라이언트 설정

### 2-1. 패키지 추가

`gear_freak_flutter/pubspec.yaml` 파일 수정:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0  # 포그라운드 알림용
```

터미널에서 패키지 설치:
```bash
cd gear_freak_flutter
flutter pub get
```

### 2-2. Android 설정

#### build.gradle (프로젝트 레벨)

`gear_freak_flutter/android/build.gradle` 파일의 `buildscript` 섹션에 추가:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath 'com.google.gms:google-services:4.4.0'  // 추가
    }
}
```

#### build.gradle (앱 레벨)

`gear_freak_flutter/android/app/build.gradle` 파일 맨 아래에 추가:

```gradle
apply plugin: 'com.google.gms.google-services'
```

#### AndroidManifest.xml

`gear_freak_flutter/android/app/src/main/AndroidManifest.xml`에 알림 채널 추가 (선택사항):

```xml
<manifest>
    <application>
        <!-- 기존 코드 -->
        
        <!-- 알림 채널 설정 (Android 8.0+) -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="chat_channel" />
    </application>
</manifest>
```

### 2-3. iOS 설정

#### Podfile

`gear_freak_flutter/ios/Podfile` 확인:

```ruby
platform :ios, '12.0'  # 최소 iOS 12.0 이상
```

터미널에서 CocoaPods 설치:
```bash
cd gear_freak_flutter/ios
pod install
```

#### Info.plist

`gear_freak_flutter/ios/Runner/Info.plist`에 알림 권한 메시지 추가:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>채팅 메시지 알림을 받기 위해 알림 권한이 필요합니다.</string>
```

#### AppDelegate.swift

`gear_freak_flutter/ios/Runner/AppDelegate.swift` 수정:

```swift
import UIKit
import Flutter
import FirebaseCore  // 추가

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()  // 추가
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## Phase 3: 서버 측 구현

### 3-1. FCM 토큰 모델 생성

`gear_freak_server/lib/src/feature/user/model/fcm_token.spy.yaml` 파일 생성:

```yaml
### FCM 토큰 정보
class: FcmToken

table: fcm_token

fields:
  ### 사용자 ID (User.id)
  userId: int
  ### FCM 토큰
  token: String
  ### 디바이스 타입 (ios, android)
  deviceType: String?
  ### 토큰 생성/업데이트 시간
  updatedAt: DateTime?
  ### 토큰 생성 시간
  createdAt: DateTime?

indexes:
  user_id_token_unique_idx:
    fields: userId, token
    unique: true
  user_id_idx:
    fields: userId
```

### 3-2. 마이그레이션 실행

```bash
cd gear_freak_server
serverpod generate
serverpod create-migration
```

마이그레이션 파일 확인 후 적용:
```bash
serverpod apply-migrations
```

### 3-3. FCM 서비스 생성

`gear_freak_server/lib/src/common/fcm/service/fcm_service.dart` 파일 생성:

```dart
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'dart:convert';

/// FCM 알림 전송 서비스
class FcmService {
  /// FCM API URL (프로젝트 ID는 환경 변수에서 가져오기)
  static String _getFcmUrl(Session session) {
    final projectId = session.serverpod.config.get('fcm.projectId');
    if (projectId == null) {
      throw Exception('FCM 프로젝트 ID가 설정되지 않았습니다.');
    }
    return 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
  }
  
  /// FCM 액세스 토큰 획득 (서버 키 사용)
  static Future<String?> _getAccessToken(Session session) async {
    final serverKey = session.serverpod.config.get('fcm.serverKey');
    if (serverKey == null) {
      session.log('FCM 서버 키가 설정되지 않았습니다.', level: LogLevel.error);
      return null;
    }
    
    // FCM v1 API는 OAuth2 토큰이 필요하지만, 
    // 간단한 구현을 위해 서버 키를 직접 사용하는 방법도 있습니다.
    // 실제로는 Google Cloud Service Account를 사용하는 것이 권장됩니다.
    return serverKey;
  }
  
  /// FCM 알림 전송 (v1 API)
  static Future<bool> sendNotification({
    required Session session,
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken(session);
      if (accessToken == null) {
        return false;
      }
      
      final fcmUrl = _getFcmUrl(session);
      
      final message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {},
          'android': {
            'priority': 'high',
            'notification': {
              'channelId': 'chat_channel',
              'sound': 'default',
            },
          },
          'apns': {
            'headers': {
              'apns-priority': '10',
            },
            'payload': {
              'aps': {
                'sound': 'default',
                'badge': 1,
              },
            },
          },
        },
      };
      
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(message),
      );
      
      if (response.statusCode == 200) {
        session.log('FCM 알림 전송 성공: $fcmToken', level: LogLevel.info);
        return true;
      } else {
        session.log(
          'FCM 전송 실패: ${response.statusCode} - ${response.body}',
          level: LogLevel.error,
        );
        return false;
      }
    } catch (e, stackTrace) {
      session.log(
        'FCM 전송 예외: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      return false;
    }
  }
}
```

**참고**: FCM v1 API는 OAuth2 토큰이 필요합니다. 간단한 구현을 위해 레거시 API를 사용할 수도 있습니다:

```dart
/// FCM 알림 전송 (레거시 API - 더 간단함)
static Future<bool> sendNotificationLegacy({
  required Session session,
  required String fcmToken,
  required String title,
  required String body,
  Map<String, dynamic>? data,
}) async {
  try {
    final serverKey = session.serverpod.config.get('fcm.serverKey');
    if (serverKey == null) {
      session.log('FCM 서버 키가 설정되지 않았습니다.', level: LogLevel.error);
      return false;
    }
    
    final message = {
      'to': fcmToken,
      'notification': {
        'title': title,
        'body': body,
      },
      'data': data ?? {},
      'android': {
        'priority': 'high',
      },
      'apns': {
        'headers': {
          'apns-priority': '10',
        },
      },
    };
    
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Authorization': 'key=$serverKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message),
    );
    
    if (response.statusCode == 200) {
      return true;
    } else {
      session.log('FCM 전송 실패: ${response.statusCode}', level: LogLevel.error);
      return false;
    }
  } catch (e, stackTrace) {
    session.log('FCM 전송 예외: $e', exception: e, stackTrace: stackTrace, level: LogLevel.error);
    return false;
  }
}
```

### 3-4. FCM 토큰 서비스 생성

`gear_freak_server/lib/src/feature/user/service/fcm_token_service.dart` 파일 생성:

```dart
import 'package:serverpod/serverpod.dart';
import 'package:gear_freak_server/src/generated/feature/user/model/fcm_token.dart';

/// FCM 토큰 관리 서비스
class FcmTokenService {
  /// FCM 토큰 등록/업데이트
  static Future<void> registerToken({
    required Session session,
    required int userId,
    required String token,
    String? deviceType,
  }) async {
    try {
      // 기존 토큰 확인
      final existing = await FcmToken.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(userId) & t.token.equals(token),
      );
      
      if (existing != null) {
        // 기존 토큰 업데이트
        await FcmToken.db.updateRow(
          session,
          existing.copyWith(
            deviceType: deviceType,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      } else {
        // 새 토큰 등록
        await FcmToken.db.insertRow(
          session,
          FcmToken(
            userId: userId,
            token: token,
            deviceType: deviceType,
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }
    } catch (e, stackTrace) {
      session.log(
        'FCM 토큰 등록 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }
  
  /// FCM 토큰 삭제
  static Future<void> deleteToken({
    required Session session,
    required int userId,
    required String token,
  }) async {
    try {
      await FcmToken.db.delete(
        session,
        where: (t) => t.userId.equals(userId) & t.token.equals(token),
      );
    } catch (e, stackTrace) {
      session.log(
        'FCM 토큰 삭제 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }
  
  /// 사용자 ID로 FCM 토큰 목록 조회
  static Future<List<FcmToken>> getTokensByUserId({
    required Session session,
    required int userId,
  }) async {
    try {
      return await FcmToken.db.find(
        session,
        where: (t) => t.userId.equals(userId),
      );
    } catch (e, stackTrace) {
      session.log(
        'FCM 토큰 조회 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      return [];
    }
  }
}
```

### 3-5. FCM 엔드포인트 생성

`gear_freak_server/lib/src/feature/user/endpoint/fcm_endpoint.dart` 파일 생성:

```dart
import 'package:serverpod/serverpod.dart';
import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
import 'package:gear_freak_server/src/feature/user/endpoint/endpoint.dart';

/// FCM 토큰 관리 엔드포인트
class FcmEndpoint extends Endpoint with AuthenticatedMixin {
  /// FCM 토큰 등록/업데이트
  Future<void> registerFcmToken(
    Session session,
    String token,
    String? deviceType,
  ) async {
    final userId = await session.authenticatedUserId;
    if (userId == null) {
      throw Exception('인증되지 않은 사용자입니다.');
    }
    
    await FcmTokenService.registerToken(
      session: session,
      userId: userId,
      token: token,
      deviceType: deviceType,
    );
  }
  
  /// FCM 토큰 삭제 (로그아웃 시)
  Future<void> deleteFcmToken(
    Session session,
    String token,
  ) async {
    final userId = await session.authenticatedUserId;
    if (userId == null) {
      throw Exception('인증되지 않은 사용자입니다.');
    }
    
    await FcmTokenService.deleteToken(
      session: session,
      userId: userId,
      token: token,
    );
  }
}
```

`gear_freak_server/lib/src/feature/user/endpoint/endpoint.dart` 파일에 추가:

```dart
export 'fcm_endpoint.dart';
```

### 3-6. 채팅 서비스에 FCM 알림 추가

`gear_freak_server/lib/src/feature/chat/service/chat_service.dart` 파일 수정:

`sendMessage` 메서드의 Redis 브로드캐스팅 이후에 추가:

```dart
// 8. 🚀 Redis 기반 글로벌 브로드캐스팅
await session.messages.postMessage(
  'chat_room_$chatRoomId',
  response,
  global: true,
);

// 9. 📱 FCM 알림 발송 (비동기, 실패해도 메시지 전송은 성공)
_ = _sendFcmNotification(
  session: session,
  chatRoomId: chatRoomId,
  senderId: userId,
  senderNickname: user?.nickname ?? '알 수 없음',
  messageContent: content,
  messageType: savedMessage.messageType,
);

return response;
```

`ChatService` 클래스에 다음 메서드 추가:

```dart
import 'package:gear_freak_server/src/common/fcm/service/fcm_service.dart';
import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
import 'package:gear_freak_server/src/generated/feature/chat/model/chat_participant.dart';

/// FCM 알림 발송 (비동기)
static Future<void> _sendFcmNotification({
  required Session session,
  required int chatRoomId,
  required int senderId,
  required String senderNickname,
  required String messageContent,
  required MessageType messageType,
}) async {
  try {
    // 채팅방 참여자 조회 (발신자 제외)
    final participants = await ChatParticipant.db.find(
      session,
      where: (p) => p.chatRoomId.equals(chatRoomId) &
          p.userId.notEquals(senderId) &
          p.isActive.equals(true),
    );
    
    if (participants.isEmpty) return;
    
    // 메시지 내용 요약
    String body = messageContent;
    if (messageType == MessageType.image) {
      body = '📷 사진';
    } else if (messageType == MessageType.file) {
      body = '🎬 동영상';
    } else if (body.length > 50) {
      body = '${body.substring(0, 50)}...';
    }
    
    // 각 참여자의 FCM 토큰 조회 및 알림 발송
    for (final participant in participants) {
      final tokens = await FcmTokenService.getTokensByUserId(
        session: session,
        userId: participant.userId!,
      );
      
      // 각 토큰에 알림 발송
      for (final token in tokens) {
        await FcmService.sendNotificationLegacy(
          session: session,
          fcmToken: token.token,
          title: senderNickname,
          body: body,
          data: {
            'type': 'chat_message',
            'chatRoomId': chatRoomId.toString(),
            'senderId': senderId.toString(),
          },
        );
      }
    }
  } catch (e, stackTrace) {
    // FCM 실패는 로그만 남기고 메시지 전송에는 영향 없음
    session.log(
      'FCM 알림 발송 실패: $e',
      exception: e,
      stackTrace: stackTrace,
      level: LogLevel.warning,
    );
  }
}
```

### 3-7. 서버 환경 변수 설정

`gear_freak_server/config/development.yaml` 파일에 추가:

```yaml
fcm:
  serverKey: 'YOUR_FCM_SERVER_KEY_HERE'  # Firebase Console에서 복사한 서버 키
  projectId: 'gear-freak'  # Firebase 프로젝트 ID (v1 API 사용 시)
```

**보안 주의사항**:
- `config/development.yaml`은 Git에 커밋하지 않기
- `.gitignore`에 추가되어 있는지 확인
- 프로덕션 환경에서는 환경 변수나 시크릿 관리 서비스 사용

### 3-8. HTTP 패키지 추가

`gear_freak_server/pubspec.yaml`에 추가 (없는 경우):

```yaml
dependencies:
  http: ^1.1.0
```

---

## Phase 4: 클라이언트 구현

### 4-1. FCM 서비스 생성

`gear_freak_flutter/lib/common/service/fcm_service.dart` 파일 생성:

```dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';
import 'package:go_router/go_router.dart';

/// FCM 알림 서비스
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  static String? _currentToken;
  
  /// FCM 초기화
  static Future<void> initialize() async {
    try {
      // 1. 로컬 알림 초기화 (포그라운드 알림용)
      await _initializeLocalNotifications();
      
      // 2. 알림 권한 요청
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 3. 토큰 획득 및 서버 등록
        _currentToken = await _messaging.getToken();
        if (_currentToken != null) {
          debugPrint('FCM 토큰: $_currentToken');
          await _registerTokenToServer(_currentToken!);
        }
        
        // 4. 토큰 갱신 리스너
        _messaging.onTokenRefresh.listen((newToken) {
          _currentToken = newToken;
          debugPrint('FCM 토큰 갱신: $newToken');
          _registerTokenToServer(newToken);
        });
        
        // 5. 포그라운드 메시지 핸들러 (앱이 열려있을 때)
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // 6. 백그라운드 메시지 핸들러 (앱이 백그라운드에 있을 때 알림 클릭)
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
        
        // 7. 앱이 종료된 상태에서 알림 클릭으로 앱 실행
        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleBackgroundMessage(initialMessage);
        }
      } else {
        debugPrint('FCM 알림 권한이 거부되었습니다.');
      }
    } catch (e, stackTrace) {
      debugPrint('FCM 초기화 실패: $e');
      debugPrint('스택 트레이스: $stackTrace');
    }
  }
  
  /// 로컬 알림 초기화 (포그라운드 알림용)
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // 로컬 알림 클릭 시 처리
        if (details.payload != null) {
          _handleNotificationClick(details.payload!);
        }
      },
    );
    
    // Android 알림 채널 생성
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'chat_channel',
        '채팅 알림',
        description: '채팅 메시지 알림',
        importance: Importance.high,
        playSound: true,
      );
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }
  
  /// 포그라운드 메시지 처리 (앱이 열려있을 때)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // 포그라운드에서는 FCM이 자동으로 알림을 표시하지 않으므로
    // 로컬 알림을 수동으로 표시해야 함
    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        data: message.data,
      );
    }
  }
  
  /// 로컬 알림 표시
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      '채팅 알림',
      channelDescription: '채팅 메시지 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // payload에 채팅방 ID 포함
    final payload = data != null && data['chatRoomId'] != null
        ? 'chatRoomId:${data['chatRoomId']}'
        : null;
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  /// 백그라운드 메시지 처리 (알림 클릭 시)
  static void _handleBackgroundMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'chat_message' && data['chatRoomId'] != null) {
      _navigateToChatRoom(data['chatRoomId']);
    }
  }
  
  /// 알림 클릭 처리 (로컬 알림 또는 백그라운드 알림)
  static void _handleNotificationClick(String payload) {
    if (payload.startsWith('chatRoomId:')) {
      final chatRoomId = payload.split(':')[1];
      _navigateToChatRoom(chatRoomId);
    }
  }
  
  /// 채팅방으로 이동
  static void _navigateToChatRoom(String chatRoomId) {
    // GoRouter를 사용하여 채팅방으로 이동
    // navigatorKey를 사용하거나 다른 방법으로 context 접근
    // 예: router.push('/chat/$chatRoomId');
    debugPrint('채팅방으로 이동: $chatRoomId');
    // TODO: 실제 라우팅 구현
  }
  
  /// 서버에 FCM 토큰 등록
  static Future<void> _registerTokenToServer(String token) async {
    try {
      final client = PodService.instance.client;
      await client.fcm.registerFcmToken(
        token,
        Platform.isIOS ? 'ios' : 'android',
      );
      debugPrint('FCM 토큰 서버 등록 성공');
    } catch (e) {
      debugPrint('FCM 토큰 등록 실패: $e');
    }
  }
  
  /// FCM 토큰 삭제 (로그아웃 시)
  static Future<void> deleteToken() async {
    if (_currentToken != null) {
      try {
        final client = PodService.instance.client;
        await client.fcm.deleteFcmToken(_currentToken!);
        _currentToken = null;
        debugPrint('FCM 토큰 삭제 성공');
      } catch (e) {
        debugPrint('FCM 토큰 삭제 실패: $e');
      }
    }
  }
}

/// 백그라운드 메시지 핸들러 (최상위 함수)
/// 앱이 백그라운드에 있을 때 FCM이 이 함수를 호출함
/// 주의: 이 함수는 알림을 표시하지 않음 (FCM이 자동으로 표시)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서 메시지 수신 시 처리
  // 예: 로컬 DB에 저장, 통계 수집 등
  debugPrint('백그라운드 메시지 수신: ${message.messageId}');
  debugPrint('제목: ${message.notification?.title}');
  debugPrint('내용: ${message.notification?.body}');
  debugPrint('데이터: ${message.data}');
  
  // 주의: 여기서는 알림을 표시하지 않음
  // FCM이 자동으로 알림을 표시함 (서버에서 notification 필드를 보냈을 경우)
}
```

### 4-2. main.dart 수정

`gear_freak_flutter/lib/main.dart` 파일 수정:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gear_freak_flutter/common/service/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp();
  
  // ⚠️ 중요: 백그라운드 메시지 핸들러는 runApp() 전에 등록해야 함
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // .env 파일 로드
  await dotenv.load(fileName: '.env');
  
  // ... 기존 코드 ...
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 4-3. 로그인 시 FCM 초기화

`gear_freak_flutter/lib/feature/auth/presentation/provider/auth_notifier.dart` 파일 수정:

로그인 성공 후 FCM 초기화:

```dart
import 'package:gear_freak_flutter/common/service/fcm_service.dart';

// 로그인 성공 후
await FcmService.initialize();
```

### 4-4. 로그아웃 시 FCM 토큰 삭제

`gear_freak_flutter/lib/feature/auth/presentation/provider/auth_notifier.dart` 파일 수정:

로그아웃 시 토큰 삭제:

```dart
// 로그아웃 시
await FcmService.deleteToken();
```

### 4-5. 라우팅 설정 (알림 클릭 시 채팅방 이동)

`gear_freak_flutter/lib/common/route/router_provider.dart` 또는 라우터 설정 파일에서:

```dart
// navigatorKey를 전역으로 설정
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// FcmService의 _navigateToChatRoom 메서드 수정
static void _navigateToChatRoom(String chatRoomId) {
  final context = navigatorKey.currentContext;
  if (context != null) {
    context.push('/chat/$chatRoomId');
  }
}
```

---

## Phase 5: 테스트

### 5-1. 앱 실행 및 토큰 확인

1. **앱 실행**
   ```bash
   cd gear_freak_flutter
   flutter run
   ```

2. **로그인**
   - 앱에서 로그인 수행
   - 로그에서 FCM 토큰 확인:
     ```
     FCM 토큰: [토큰 문자열]
     FCM 토큰 서버 등록 성공
     ```

3. **서버 로그 확인**
   - 서버에서 FCM 토큰이 DB에 저장되었는지 확인

### 5-2. Firebase Console에서 테스트 알림 발송

1. **Firebase Console 접속**
   - 프로젝트 → 클라우드 메시징 → "테스트 메시지 전송"

2. **FCM 등록 토큰 입력**
   - 앱에서 로그에 출력된 FCM 토큰 복사
   - "FCM 등록 토큰" 필드에 붙여넣기

3. **알림 제목/내용 입력**
   - 제목: "테스트 알림"
   - 알림 텍스트: "FCM 테스트 메시지입니다"

4. **테스트 전송**
   - "테스트" 버튼 클릭
   - 앱에서 알림 수신 확인

### 5-3. 실제 채팅 테스트

1. **두 기기 준비**
   - 기기 A: 사용자 1로 로그인
   - 기기 B: 사용자 2로 로그인

2. **채팅방 생성**
   - 기기 A에서 기기 B와 채팅 시작

3. **메시지 전송**
   - 기기 A에서 메시지 전송
   - 기기 B에서 알림 수신 확인

4. **알림 클릭 테스트**
   - 기기 B에서 알림 클릭
   - 해당 채팅방으로 이동하는지 확인

### 5-4. 다양한 시나리오 테스트

- ✅ **포그라운드 알림**: 앱이 열려있을 때 알림 수신
- ✅ **백그라운드 알림**: 앱이 백그라운드에 있을 때 알림 수신
- ✅ **앱 종료 알림**: 앱이 완전히 종료된 상태에서 알림 수신
- ✅ **이미지 메시지 알림**: 이미지 전송 시 알림 내용 확인
- ✅ **동영상 메시지 알림**: 동영상 전송 시 알림 내용 확인

---

## 트러블슈팅

### 문제 1: FCM 토큰이 생성되지 않음

**원인**:
- `google-services.json` 파일이 올바른 위치에 없음
- Firebase 초기화가 되지 않음

**해결**:
1. `google-services.json` 파일 위치 확인
2. `main.dart`에서 `Firebase.initializeApp()` 호출 확인
3. Android의 경우 `build.gradle`에 `google-services` 플러그인 적용 확인

### 문제 2: 백그라운드에서 알림이 표시되지 않음

**원인**:
- 서버에서 `notification` 필드를 보내지 않음
- 알림 권한이 거부됨

**해결**:
1. 서버 코드에서 `notification` 필드 포함 확인
2. 앱 설정에서 알림 권한 확인
3. iOS의 경우 `Info.plist`에 권한 메시지 추가 확인

### 문제 3: 포그라운드에서 알림이 표시되지 않음

**원인**:
- `flutter_local_notifications` 초기화 실패
- 로컬 알림 권한 미승인

**해결**:
1. `_initializeLocalNotifications()` 메서드 호출 확인
2. Android 알림 채널 생성 확인
3. iOS 알림 권한 요청 확인

### 문제 4: 알림 클릭 시 앱이 열리지 않음

**원인**:
- `onMessageOpenedApp` 핸들러 미등록
- 라우팅 로직 오류

**해결**:
1. `FirebaseMessaging.onMessageOpenedApp.listen()` 등록 확인
2. `_navigateToChatRoom()` 메서드 구현 확인
3. GoRouter 설정 확인

### 문제 5: 서버에서 FCM 전송 실패

**원인**:
- FCM 서버 키가 잘못됨
- FCM API URL 오류
- 네트워크 오류

**해결**:
1. 서버 키가 올바른지 확인 (Firebase Console에서 재발급)
2. 서버 로그에서 에러 메시지 확인
3. FCM API 엔드포인트 URL 확인

### 문제 6: iOS에서 알림이 작동하지 않음

**원인**:
- APNs 인증서 미설정
- `GoogleService-Info.plist` 파일 미추가
- Xcode에서 파일이 프로젝트에 포함되지 않음

**해결**:
1. Firebase Console에서 APNs 인증서 업로드
2. `GoogleService-Info.plist` 파일이 Xcode 프로젝트에 포함되었는지 확인
3. `Podfile`에서 최소 iOS 버전 확인 (12.0 이상)

---

## 추가 개선 사항

### 1. 현재 채팅방에 있는 사용자는 알림 생략

클라이언트에서 채팅방 진입 시 서버에 "현재 채팅방 ID" 전송하고, 서버에서 해당 사용자는 FCM 발송 제외:

```dart
// 클라이언트: 채팅방 진입 시
await client.chat.setCurrentChatRoom(chatRoomId);

// 서버: FCM 발송 전에 확인
final currentChatRoom = await getCurrentChatRoom(userId);
if (currentChatRoom == chatRoomId) {
  // 알림 발송 생략
  return;
}
```

### 2. 알림 배지 카운트

읽지 않은 메시지 수를 알림 배지에 표시:

```dart
// 서버에서 알림 발송 시
'apns': {
  'payload': {
    'aps': {
      'badge': unreadCount,  // 읽지 않은 메시지 수
    },
  },
}
```

### 3. 알림 사운드 커스터마이징

커스텀 알림 사운드 사용:

```dart
'android': {
  'notification': {
    'sound': 'custom_sound.mp3',
  },
}
```

---

## 참고 자료

- [Firebase Cloud Messaging 공식 문서](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging 패키지](https://pub.dev/packages/firebase_messaging)
- [Flutter Local Notifications 패키지](https://pub.dev/packages/flutter_local_notifications)
- [FCM HTTP v1 API 문서](https://firebase.google.com/docs/cloud-messaging/migrate-v1)

---

## 체크리스트

### Firebase Console
- [ ] Android 앱 등록 완료
- [ ] `google-services.json` 다운로드 및 배치
- [ ] iOS 앱 등록 완료 (선택)
- [ ] `GoogleService-Info.plist` 다운로드 및 배치 (선택)
- [ ] FCM 서버 키 발급

### 클라이언트 설정
- [ ] 패키지 추가 (`firebase_core`, `firebase_messaging`, `flutter_local_notifications`)
- [ ] Android `build.gradle` 설정
- [ ] iOS `Podfile` 및 `Info.plist` 설정
- [ ] `main.dart`에서 Firebase 초기화

### 서버 구현
- [ ] FCM 토큰 모델 생성 및 마이그레이션
- [ ] FCM 서비스 구현
- [ ] FCM 토큰 서비스 구현
- [ ] FCM 엔드포인트 구현
- [ ] 채팅 서비스에 FCM 알림 추가
- [ ] 환경 변수 설정

### 클라이언트 구현
- [ ] FCM 서비스 구현
- [ ] 로그인 시 FCM 초기화
- [ ] 로그아웃 시 토큰 삭제
- [ ] 알림 클릭 시 라우팅 구현

### 테스트
- [ ] FCM 토큰 생성 확인
- [ ] Firebase Console에서 테스트 알림 발송
- [ ] 실제 채팅 알림 테스트
- [ ] 포그라운드/백그라운드/앱 종료 상태 테스트

---

**작성일**: 2024년
**프로젝트**: gear-freak
**버전**: 1.0.0

