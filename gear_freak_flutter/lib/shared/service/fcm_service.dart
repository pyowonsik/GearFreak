import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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

  /// FCM 메시지 수신 콜백 (chatRoomId를 받아서 채팅방 정보 갱신)
  void Function(int chatRoomId)? onMessageReceived;

  /// FCM 알림 수신 콜백 (알림 타입 수신 시 호출)
  void Function()? onNotificationReceived;

  /// FCM 초기화 및 토큰 등록
  /// 로그인 성공 후 호출해야 합니다.
  /// [router]는 딥링크 처리를 위한 GoRouter 인스턴스입니다. (선택사항)
  Future<void> initialize({GoRouter? router}) async {
    _router = router;
    try {
      debugPrint('📱 FCM 초기화 시작...');

      // 알림 권한 요청
      final settings = await _messaging.requestPermission();

      debugPrint('📱 FCM 권한 상태: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // FCM 토큰 가져오기
        try {
          final token = await _messaging.getToken();
          if (token != null) {
            _currentToken = token;
            debugPrint('📱 FCM 토큰 가져오기 성공: ${token.substring(0, 30)}...');
            await _registerTokenToServer(token);
          } else {
            debugPrint('⚠️ FCM 토큰이 null입니다.');
          }
        } catch (e) {
          debugPrint('⚠️ FCM 토큰 가져오기 실패 (시뮬레이터일 수 있음): $e');
        }

        // 포그라운드 메시지 리스너
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('========================================');
          debugPrint('📱 [포그라운드] FCM 알림 수신');
          debugPrint('메시지 ID: ${message.messageId}');
          debugPrint('제목: ${message.notification?.title}');
          debugPrint('내용: ${message.notification?.body}');
          debugPrint('데이터: ${message.data}');
          debugPrint('========================================');
          _handleMessageReceived(message);
        });

        // 백그라운드→포그라운드 알림 탭 처리는 main.dart에서 처리
        // (로그인 여부와 관계없이 앱 시작 시점에 리스너 등록되어야 하므로)

        // 토큰 갱신 리스너
        _messaging.onTokenRefresh.listen((newToken) {
          _currentToken = newToken;
          debugPrint('📱 FCM 토큰 갱신됨: ${newToken.substring(0, 30)}...');
          _registerTokenToServer(newToken);
        });
      } else {
        debugPrint('⚠️ FCM 알림 권한이 거부되었습니다.');
      }
    } catch (e) {
      debugPrint('⚠️ FCM 초기화 실패 (시뮬레이터일 수 있음): $e');
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
        debugPrint('✅ FCM 토큰 서버 등록 성공: ${token.substring(0, 20)}...');
        return; // 성공 시 즉시 반환
      } catch (e) {
        debugPrint('❌ FCM 토큰 서버 등록 실패 (시도 $attempt/$retryCount): $e');

        if (attempt < retryCount) {
          // 지수 백오프: 2초, 4초, 8초...
          final delay = Duration(seconds: attempt * 2);
          debugPrint('⏳ ${delay.inSeconds}초 후 재시도...');
          await Future<void>.delayed(delay);
        }
      }
    }

    debugPrint('⚠️ FCM 토큰 등록 최종 실패 - 다음 앱 실행 시 재시도됩니다');
  }

  /// FCM 토큰 삭제 (로그아웃 시 호출)
  Future<void> deleteToken() async {
    try {
      if (_currentToken != null) {
        final client = PodService.instance.client;
        await client.fcm.deleteFcmToken(_currentToken!);
        debugPrint('✅ FCM 토큰 서버 삭제 성공');
      }
    } catch (e) {
      debugPrint('❌ FCM 토큰 서버 삭제 실패: $e');
    } finally {
      // 성공/실패 관계없이 로컬 토큰 초기화
      _currentToken = null;
    }
  }

  /// 알림 탭 처리 (채팅 화면 또는 리뷰 작성 화면으로 이동)
  void handleNotificationTap(RemoteMessage message, {GoRouter? router}) {
    final data = message.data;
    final targetRouter = router ?? _router;

    // 채팅 메시지 알림인 경우
    if (data['type'] == 'chat_message' &&
        data['chatRoomId'] != null &&
        data['productId'] != null) {
      final chatRoomId = data['chatRoomId'];
      final productId = data['productId'];

      debugPrint('🔗 채팅 화면으로 이동: productId=$productId, chatRoomId=$chatRoomId');

      // 라우터가 설정되어 있으면 채팅 화면으로 이동
      if (targetRouter != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          targetRouter.push('/chat/$productId?chatRoomId=$chatRoomId');
          debugPrint('✅ 채팅 화면으로 이동 완료');
        });
      } else {
        debugPrint('⚠️ GoRouter가 설정되지 않아 채팅 화면으로 이동할 수 없습니다');
      }
    }
    // 후기 받음 알림인 경우 → 알림 화면으로 이동
    else if (data['type'] == 'review_received') {
      debugPrint('🔗 알림 화면으로 이동: review_received 알림');

      // 라우터가 설정되어 있으면 알림 화면으로 이동
      if (targetRouter != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          targetRouter.push('/notifications');
          debugPrint('✅ 알림 화면으로 이동 완료');
        });
      } else {
        debugPrint('⚠️ GoRouter가 설정되지 않아 알림 화면으로 이동할 수 없습니다');
      }
    }
  }

  /// GoRouter 설정 (앱 초기화 시 호출)
  Future<void> setRouter(GoRouter router) async {
    _router = router;
  }

  /// FCM 메시지 수신 콜백 설정
  Future<void> setOnMessageReceived(
    void Function(int chatRoomId) callback,
  ) async {
    onMessageReceived = callback;
  }

  /// FCM 알림 수신 콜백 설정
  Future<void> setOnNotificationReceived(
    void Function() callback,
  ) async {
    onNotificationReceived = callback;
  }

  /// FCM 메시지 수신 처리 (포그라운드/백그라운드)
  void _handleMessageReceived(RemoteMessage message) {
    final data = message.data;

    // 채팅 메시지 알림인 경우
    if (data['type'] == 'chat_message' && data['chatRoomId'] != null) {
      final chatRoomId = int.tryParse(data['chatRoomId'].toString());
      if (chatRoomId != null && onMessageReceived != null) {
        debugPrint('📩 FCM 알림으로 채팅방 정보 갱신 트리거: chatRoomId=$chatRoomId');
        onMessageReceived!(chatRoomId);
      }
    }
    // 알림인 경우 (review_received 등)
    else if (data['type'] == 'review_received' &&
        onNotificationReceived != null) {
      debugPrint('📩 FCM 알림 수신: review_received');
      onNotificationReceived!();
    }
  }
}
