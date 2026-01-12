import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/common/authenticated_mixin.dart';

import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';

/// FCM 엔드포인트
/// FCM 토큰 등록 및 삭제를 처리합니다.
class FcmEndpoint extends Endpoint with AuthenticatedMixin {
  // ==================== Public Methods ====================

  /// FCM 토큰 등록
  ///
  /// [session]: Serverpod 세션
  /// [token]: FCM 토큰
  /// [deviceType]: 디바이스 타입 (ios, android)
  /// Returns: true = 성공, false = 실패
  Future<bool> registerFcmToken(
    Session session,
    String token,
    String? deviceType,
  ) async {
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await FcmTokenService.registerToken(
      session: session,
      userId: user.id!,
      token: token,
      deviceType: deviceType,
    );
  }

  /// FCM 토큰 삭제
  ///
  /// [session]: Serverpod 세션
  /// [token]: 삭제할 FCM 토큰
  /// Returns: true = 성공, false = 실패
  Future<bool> deleteFcmToken(
    Session session,
    String token,
  ) async {
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await FcmTokenService.deleteToken(
      session: session,
      userId: user.id!,
      token: token,
    );
  }
}

