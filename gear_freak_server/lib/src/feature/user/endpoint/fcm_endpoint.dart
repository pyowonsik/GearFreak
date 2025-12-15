import 'package:gear_freak_server/src/common/authenticated_mixin.dart';
import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';
import 'package:serverpod/serverpod.dart';

/// FCM 엔드포인트
/// FCM 토큰 등록 및 삭제를 처리합니다.
class FcmEndpoint extends Endpoint with AuthenticatedMixin {
  /// FCM 토큰 등록
  /// 
  /// [token]은 FCM 토큰입니다.
  /// [deviceType]은 디바이스 타입입니다 (ios, android).
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
  /// [token]은 FCM 토큰입니다.
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

