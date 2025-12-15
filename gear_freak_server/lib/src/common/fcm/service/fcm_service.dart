import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

/// FCM 서비스
/// Firebase Cloud Messaging API를 사용하여 푸시 알림을 전송합니다.
class FcmService {
  /// FCM 프로젝트 ID 가져오기
  static String? _getProjectId(Session session) {
    // 환경 변수에서 가져오기
    final projectId = Platform.environment['FCM_PROJECT_ID'];
    if (projectId == null || projectId.isEmpty) {
      print('⚠️ FCM_PROJECT_ID 환경 변수가 설정되지 않았습니다.');
      print(
          '⚠️ 현재 환경 변수: ${Platform.environment.keys.where((k) => k.contains('FCM')).join(', ')}');
    }
    return projectId;
  }

  /// 서비스 계정 JSON 파일 경로 가져오기
  static String? _getServiceAccountPath(Session session) {
    // 환경 변수에서 가져오기
    return Platform.environment['FCM_SERVICE_ACCOUNT_PATH'];
  }

  /// OAuth2 액세스 토큰 가져오기
  static Future<String?> _getAccessToken(Session session) async {
    // Session이 닫힌 후에도 실행될 수 있으므로 안전한 로깅 헬퍼
    void safeLog(String message, {LogLevel level = LogLevel.error}) {
      try {
        session.log(message, level: level);
      } catch (e) {
        // Session이 닫혔으면 print 사용
        print('📱 $message');
      }
    }

    try {
      final serviceAccountPath = _getServiceAccountPath(session);
      if (serviceAccountPath == null) {
        safeLog('FCM 서비스 계정 JSON 파일 경로가 설정되지 않았습니다.');
        return null;
      }

      final serviceAccountFile = File(serviceAccountPath);
      if (!await serviceAccountFile.exists()) {
        safeLog('FCM 서비스 계정 JSON 파일을 찾을 수 없습니다: $serviceAccountPath');
        return null;
      }

      final serviceAccountJson = await serviceAccountFile.readAsString();
      final serviceAccount =
          jsonDecode(serviceAccountJson) as Map<String, dynamic>;

      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);
      final client = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      return client.credentials.accessToken.data;
    } catch (e, stackTrace) {
      try {
        session.log(
          'OAuth2 토큰 가져오기 실패: $e',
          exception: e,
          stackTrace: stackTrace,
          level: LogLevel.error,
        );
      } catch (_) {
        // Session이 닫혔으면 print 사용
        print('❌ OAuth2 토큰 가져오기 실패: $e');
        print('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// FCM 알림 전송
  ///
  /// [fcmToken]은 수신자의 FCM 토큰입니다.
  /// [title]은 알림 제목입니다.
  /// [body]는 알림 본문입니다.
  /// [data]는 추가 데이터입니다 (선택사항).
  ///
  /// 성공 시 true를 반환하고, 실패 시 false를 반환합니다.
  static Future<bool> sendNotification({
    required Session session,
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Session이 닫힌 후에도 실행될 수 있으므로 안전한 로깅 헬퍼
    void safeLog(String message, {LogLevel level = LogLevel.info}) {
      try {
        session.log(message, level: level);
      } catch (e) {
        // Session이 닫혔으면 print 사용
        print('📱 $message');
      }
    }

    try {
      final projectId = _getProjectId(session);
      if (projectId == null) {
        safeLog('FCM 프로젝트 ID가 설정되지 않았습니다.', level: LogLevel.error);
        return false;
      }

      // OAuth2 액세스 토큰 가져오기
      final accessToken = await _getAccessToken(session);
      if (accessToken == null) {
        return false;
      }

      // FCM V1 API 엔드포인트
      final url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      // FCM V1 API 메시지 형식
      final message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data':
              data?.map((key, value) => MapEntry(key, value.toString())) ?? {},
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'chat_channel',
            },
          },
          'apns': {
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
                'badge': 1,
              },
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        safeLog(
          '✅ FCM 알림 전송 성공: '
          'token=${fcmToken.substring(0, 20)}..., '
          'title="$title", '
          'body="$body", '
          'response=$responseBody',
        );
        return true;
      } else {
        safeLog(
          '❌ FCM 알림 전송 실패: '
          'statusCode=${response.statusCode}, '
          'token=${fcmToken.substring(0, 20)}..., '
          'title="$title", '
          'body="$body", '
          'error=${response.body}',
          level: LogLevel.error,
        );
        return false;
      }
    } catch (e, stackTrace) {
      try {
        session.log(
          'FCM 알림 전송 예외: $e',
          exception: e,
          stackTrace: stackTrace,
          level: LogLevel.error,
        );
      } catch (_) {
        // Session이 닫혔으면 print 사용
        print('❌ FCM 알림 전송 예외: $e');
        print('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// 여러 FCM 토큰에 알림 전송 (병렬 처리)
  ///
  /// [fcmTokens]는 수신자들의 FCM 토큰 리스트입니다.
  /// [title]은 알림 제목입니다.
  /// [body]는 알림 본문입니다.
  /// [data]는 추가 데이터입니다 (선택사항).
  ///
  /// 성공한 전송 수를 반환합니다.
  static Future<int> sendNotifications({
    required Session session,
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (fcmTokens.isEmpty) {
      return 0;
    }

    // 병렬로 모든 알림 전송
    final futures = fcmTokens.map((token) => sendNotification(
          session: session,
          fcmToken: token,
          title: title,
          body: body,
          data: data,
        ));

    final results = await Future.wait(futures);
    final successCount = results.where((result) => result == true).length;
    final failureCount = fcmTokens.length - successCount;

    // Session이 닫힌 후에도 실행될 수 있으므로 안전한 로깅
    try {
      session.log(
        '📱 FCM 알림 전송 완료: '
        '전체=${fcmTokens.length}, '
        '성공=$successCount, '
        '실패=$failureCount, '
        'title="$title", '
        'body="$body"',
        level: LogLevel.info,
      );
    } catch (e) {
      // Session이 닫혔으면 print 사용
      print(
        '📱 FCM 알림 전송 완료: '
        '전체=${fcmTokens.length}, '
        '성공=$successCount, '
        '실패=$failureCount, '
        'title="$title", '
        'body="$body"',
      );
    }

    return successCount;
  }
}
