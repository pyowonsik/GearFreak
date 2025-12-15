import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:gear_freak_flutter/common/service/pod_service.dart';

/// FCM 서비스
/// Firebase Cloud Messaging 토큰 관리 및 알림 처리를 담당합니다.
class FcmService {
  FcmService._();

  /// FCM 서비스 인스턴스
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _currentToken;

  /// FCM 초기화 및 토큰 등록
  /// 로그인 성공 후 호출해야 합니다.
  Future<void> initialize() async {
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
        });

        // 앱이 백그라운드에서 열렸을 때 메시지 처리
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('========================================');
          debugPrint('📱 [백그라운드→포그라운드] FCM 알림으로 앱 열림');
          debugPrint('메시지 ID: ${message.messageId}');
          debugPrint('제목: ${message.notification?.title}');
          debugPrint('내용: ${message.notification?.body}');
          debugPrint('데이터: ${message.data}');
          debugPrint('========================================');
        });

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

  /// 서버에 FCM 토큰 등록
  Future<void> _registerTokenToServer(String token) async {
    try {
      final client = PodService.instance.client;
      final deviceType = Platform.isIOS ? 'ios' : 'android';

      await client.fcm.registerFcmToken(token, deviceType);
      debugPrint('✅ FCM 토큰 서버 등록 성공: ${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('❌ FCM 토큰 서버 등록 실패: $e');
    }
  }

  /// FCM 토큰 삭제 (로그아웃 시 호출)
  Future<void> deleteToken() async {
    try {
      if (_currentToken != null) {
        final client = PodService.instance.client;
        await client.fcm.deleteFcmToken(_currentToken!);
        debugPrint('✅ FCM 토큰 서버 삭제 성공');
        _currentToken = null;
      }
    } catch (e) {
      debugPrint('❌ FCM 토큰 서버 삭제 실패: $e');
    }
  }
}
