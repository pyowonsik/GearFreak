import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
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
      developer.log(
        '[FcmService] _getProjectId - warning: FCM_PROJECT_ID environment variable not set',
        name: 'FcmService',
      );
      developer.log(
        '[FcmService] _getProjectId - info: current FCM env vars - ${Platform.environment.keys.where((k) => k.contains('FCM')).join(', ')}',
        name: 'FcmService',
      );
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
        // Session이 닫혔으면 log 사용
        developer.log(message, name: 'FcmService');
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
        // Session이 닫혔으면 log 사용
        developer.log(
          '[FcmService] _getAccessToken - error: $e',
          name: 'FcmService',
          error: e,
          stackTrace: stackTrace,
        );
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
  /// [includeNotification]은 알림 표시 여부입니다 (true: 백그라운드 알림 표시, false: data만 전송).
  /// [badge]는 iOS 앱 아이콘 배지 값입니다 (null이면 배지 변경 안 함).
  ///
  /// 성공 시 true를 반환하고, 실패 시 false를 반환합니다.
  static Future<bool> sendNotification({
    required Session session,
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    bool includeNotification = true,
    int? badge,
  }) async {
    // Session이 닫힌 후에도 실행될 수 있으므로 안전한 로깅 헬퍼
    void safeLog(String message, {LogLevel level = LogLevel.info}) {
      try {
        session.log(message, level: level);
      } catch (e) {
        // Session이 닫혔으면 log 사용
        developer.log(message, name: 'FcmService');
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
      // data 페이로드에 badge 값 포함 (Android 백그라운드 핸들러에서 사용)
      final dataPayload =
          data?.map((key, value) => MapEntry(key, value.toString())) ??
              <String, String>{};
      if (badge != null) {
        dataPayload['badge'] = badge.toString();
      }

      final message = <String, dynamic>{
        'message': <String, dynamic>{
          'token': fcmToken,
          'data': dataPayload,
        },
      };

      // 알림 표시가 필요한 경우에만 notification 포함
      if (includeNotification) {
        message['message']!['notification'] = {
          'title': title,
          'body': body,
        };
        message['message']!['android'] = {
          'priority': 'high',
          'notification': {
            'channel_id': 'chat_channel',
          },
        };
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
              if (badge != null) 'badge': badge,
            },
          },
        };
      } else {
        // data만 전송하는 경우에도 priority 설정 (포그라운드에서도 받을 수 있도록)
        message['message']!['android'] = {
          'priority': 'high',
        };
        message['message']!['apns'] = {
          'headers': {
            'apns-priority': '10',
          },
          'payload': {
            'aps': {
              'content-available': 1,
            },
          },
        };
      }

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
          '[FcmService] sendNotification - success: '
          'token=${fcmToken.substring(0, 20)}..., '
          'title="$title", '
          'body="$body", '
          'response=$responseBody',
        );
        return true;
      } else {
        safeLog(
          '[FcmService] sendNotification - error: '
          'statusCode=${response.statusCode}, '
          'token=${fcmToken.substring(0, 20)}..., '
          'title="$title", '
          'body="$body", '
          'error=${response.body}',
          level: LogLevel.error,
        );

        // UNREGISTERED 에러 처리: 유효하지 않은 토큰 삭제
        if (response.statusCode == 404) {
          try {
            final errorBody =
                jsonDecode(response.body) as Map<String, dynamic>;
            final details = errorBody['error']?['details'] as List<dynamic>?;
            if (details != null) {
              for (final detail in details) {
                if (detail is Map<String, dynamic> &&
                    detail['errorCode'] == 'UNREGISTERED') {
                  // 유효하지 않은 토큰 DB에서 삭제
                  await FcmTokenService.deleteInvalidToken(
                    session: session,
                    token: fcmToken,
                  );
                  break;
                }
              }
            }
          } catch (e) {
            safeLog(
              '[FcmService] UNREGISTERED 토큰 삭제 처리 중 오류: $e',
              level: LogLevel.error,
            );
          }
        }

        return false;
      }
    } catch (e, stackTrace) {
      try {
        session.log(
          '[FcmService] sendNotification - error: $e',
          exception: e,
          stackTrace: stackTrace,
          level: LogLevel.error,
        );
      } catch (_) {
        // Session이 닫혔으면 log 사용
        developer.log(
          '[FcmService] sendNotification - error: $e',
          name: 'FcmService',
          error: e,
          stackTrace: stackTrace,
        );
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
  /// [includeNotification]은 알림 표시 여부입니다 (true: 백그라운드 알림 표시, false: data만 전송).
  /// [badge]는 iOS 앱 아이콘 배지 값입니다 (null이면 배지 변경 안 함).
  ///
  /// 성공한 전송 수를 반환합니다.
  static Future<int> sendNotifications({
    required Session session,
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    bool includeNotification = true,
    int? badge,
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
          includeNotification: includeNotification,
          badge: badge,
        ));

    final results = await Future.wait(futures);
    final successCount = results.where((result) => result == true).length;
    final failureCount = fcmTokens.length - successCount;

    // Session이 닫힌 후에도 실행될 수 있으므로 안전한 로깅
    try {
      session.log(
        '[FcmService] sendNotifications - completed: '
        'total=${fcmTokens.length}, '
        'success=$successCount, '
        'failed=$failureCount, '
        'title="$title", '
        'body="$body"',
        level: LogLevel.info,
      );
    } catch (e) {
      // Session이 닫혔으면 log 사용
      developer.log(
        '[FcmService] sendNotifications - completed: '
        'total=${fcmTokens.length}, '
        'success=$successCount, '
        'failed=$failureCount, '
        'title="$title", '
        'body="$body"',
        name: 'FcmService',
      );
    }

    return successCount;
  }
}
