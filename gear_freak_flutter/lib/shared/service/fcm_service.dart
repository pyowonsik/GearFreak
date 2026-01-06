import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:gear_freak_flutter/shared/service/pod_service.dart';
import 'package:go_router/go_router.dart';

/// FCM 서비스
/// Firebase Cloud Messaging 토큰 관리 및 알림 처리를 담당합니다.
class FcmService {
  FcmService._();

  /// FCM 서비스 인스턴스
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _currentToken;
  GoRouter? _router;

  // 스트림 구독 (메모리 누수 방지)
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// FCM 메시지 수신 콜백 (chatRoomId를 받아서 채팅방 정보 갱신)
  void Function(int chatRoomId)? onMessageReceived;

  /// FCM 알림 수신 콜백 (알림 타입 수신 시 호출)
  void Function()? onNotificationReceived;

  /// FCM 초기화 및 토큰 등록
  /// 로그인 성공 후 호출해야 합니다.
  /// 주의: setRouter()를 먼저 호출하여 라우터를 설정해야 합니다.
  Future<void> initialize() async {
    try {
      debugPrint('📱 FCM initialization started...');

      // 기존 구독 취소 (메모리 누수 방지)
      unawaited(_foregroundMessageSubscription?.cancel());
      unawaited(_tokenRefreshSubscription?.cancel());

      // 알림 권한 요청
      final settings = await _messaging.requestPermission();

      debugPrint('📱 FCM permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // FCM 토큰 가져오기
        try {
          final token = await _messaging.getToken();
          if (token != null) {
            _currentToken = token;
            debugPrint('📱 FCM token retrieved: ${token.substring(0, 30)}...');
            await _registerTokenToServer(token);
          } else {
            debugPrint('⚠️ FCM token is null');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to get FCM token (may be simulator): $e');
        }

        // 포그라운드 메시지 리스너 (구독 저장)
        _foregroundMessageSubscription =
            FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('========================================');
          debugPrint('📱 [Foreground] FCM notification received');
          debugPrint('Message ID: ${message.messageId}');
          debugPrint('Title: ${message.notification?.title}');
          debugPrint('Body: ${message.notification?.body}');
          debugPrint('Data: ${message.data}');
          debugPrint('========================================');
          _handleMessageReceived(message);
        });

        // 백그라운드→포그라운드 알림 탭 처리는 main.dart에서 처리
        // (로그인 여부와 관계없이 앱 시작 시점에 리스너 등록되어야 하므로)

        // 토큰 갱신 리스너 (구독 저장)
        _tokenRefreshSubscription =
            _messaging.onTokenRefresh.listen((newToken) {
          _currentToken = newToken;
          debugPrint('📱 FCM token refreshed: ${newToken.substring(0, 30)}...');
          _registerTokenToServer(newToken);
        });
      } else {
        debugPrint('⚠️ FCM notification permission denied');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to initialize FCM (may be simulator): $e');
    }
  }

  /// 서버에 FCM 토큰 등록 (재시도 로직 포함)
  Future<void> _registerTokenToServer(
    String token, {
    int retryCount = 3,
  }) async {
    for (var attempt = 1; attempt <= retryCount; attempt++) {
      try {
        final client = PodService.instance.client;
        final deviceType = Platform.isIOS ? 'ios' : 'android';

        await client.fcm.registerFcmToken(token, deviceType);
        debugPrint('✅ FCM token registered: ${token.substring(0, 20)}...');
        return; // 성공 시 즉시 반환
      } catch (e) {
        debugPrint(
          '❌ Failed to register FCM token (attempt $attempt/$retryCount): $e',
        );

        if (attempt < retryCount) {
          // 지수 백오프: 2초, 4초, 8초...
          final delay = Duration(seconds: attempt * 2);
          debugPrint('⏳ Retrying in ${delay.inSeconds} seconds...');
          await Future<void>.delayed(delay);
        }
      }
    }

    debugPrint(
      '⚠️ Failed to register FCM token - will retry on next app launch',
    );
  }

  /// FCM 토큰 삭제 (로그아웃 시 호출)
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
      // 성공/실패 관계없이 로컬 토큰 및 콜백 초기화
      _currentToken = null;
      onMessageReceived = null;
      onNotificationReceived = null;
    }
  }

  /// FCM 서비스 정리 (메모리 누수 방지)
  void dispose() {
    debugPrint('🗑️ [FcmService] Disposing...');
    _foregroundMessageSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    onMessageReceived = null;
    onNotificationReceived = null;
  }

  /// 알림 탭 처리 (채팅 화면 또는 리뷰 작성 화면으로 이동)
  void handleNotificationTap(RemoteMessage message, {GoRouter? router}) {
    final data = message.data;
    final targetRouter = router ?? _router;

    debugPrint('========================================');
    debugPrint('🔔 handleNotificationTap called');
    debugPrint('📦 Notification data: $data');
    debugPrint('🎯 Notification type: ${data['type']}');
    debugPrint('🚦 Router status: ${targetRouter != null ? "set" : "null"}');
    debugPrint('📱 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
    debugPrint('========================================');

    // 채팅 메시지 알림인 경우
    if (data['type'] == 'chat_message' &&
        data['chatRoomId'] != null &&
        data['productId'] != null) {
      final chatRoomId = data['chatRoomId'];
      final productId = data['productId'];
      final route = '/chat/$productId?chatRoomId=$chatRoomId';

      debugPrint(
        '🔗 Navigating to chat: productId=$productId, chatRoomId=$chatRoomId',
      );

      if (targetRouter != null) {
        _navigateWhenReady(targetRouter, route);
      } else {
        debugPrint('⚠️ GoRouter not set, cannot navigate to chat');
      }
    }
    // 후기 받음 알림인 경우 → 알림 화면으로 이동
    else if (data['type'] == 'review_received') {
      debugPrint('🔗 Navigating to notifications: review_received');

      if (targetRouter != null) {
        _navigateWhenReady(targetRouter, '/notifications');
      } else {
        debugPrint('⚠️ GoRouter not set, cannot navigate to notifications');
      }
    } else {
      debugPrint(
        '⚠️ Unknown notification type or missing data: ${data['type']}',
      );
    }
  }

  /// 라우터가 준비될 때까지 대기 후 네비게이션
  ///
  /// WidgetsBinding을 사용하여 다음 프레임이 렌더링될 때까지 대기합니다.
  /// 이 방식은 고정된 delay보다 안전하고 빠릅니다.
  Future<void> _navigateWhenReady(GoRouter router, String route) async {
    try {
      debugPrint('⏳ Waiting for router to be ready...');

      // 다음 프레임까지 대기 (위젯 트리가 완전히 빌드될 때까지)
      await WidgetsBinding.instance.endOfFrame;

      // 추가 안전장치: 한 프레임 더 대기
      await Future<void>.delayed(const Duration(milliseconds: 100));

      debugPrint('🚀 Executing navigation: $route');
      await router.push(route);
      debugPrint('✅ Navigation completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Navigation failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// GoRouter 설정 (앱 초기화 시 호출)
  // ignore: use_setters_to_change_properties
  void setRouter(GoRouter router) {
    _router = router;
  }

  /// FCM 메시지 수신 콜백 설정
  // ignore: use_setters_to_change_properties
  void setOnMessageReceived(void Function(int chatRoomId) callback) {
    onMessageReceived = callback;
  }

  /// FCM 알림 수신 콜백 설정
  // ignore: use_setters_to_change_properties
  void setOnNotificationReceived(void Function() callback) {
    onNotificationReceived = callback;
  }

  /// FCM 메시지 수신 처리 (포그라운드/백그라운드)
  void _handleMessageReceived(RemoteMessage message) {
    final data = message.data;

    // 채팅 메시지 알림인 경우
    if (data['type'] == 'chat_message' && data['chatRoomId'] != null) {
      final chatRoomId = int.tryParse(data['chatRoomId'].toString());
      if (chatRoomId != null && onMessageReceived != null) {
        debugPrint('📩 Refreshing chat room data: chatRoomId=$chatRoomId');
        onMessageReceived!(chatRoomId);
      }
    }
    // 알림인 경우 (review_received 등)
    else if (data['type'] == 'review_received' &&
        onNotificationReceived != null) {
      debugPrint('📩 FCM notification received: review_received');
      onNotificationReceived!();
    }
  }
}
