import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// FCM 토큰 서비스
/// FCM 토큰 관련 비즈니스 로직을 처리합니다.
class FcmTokenService {
  /// FCM 토큰 등록 또는 업데이트
  ///
  /// [userId]는 사용자 ID입니다.
  /// [token]은 FCM 토큰입니다.
  /// [deviceType]은 디바이스 타입입니다 (ios, android).
  ///
  /// 성공 시 true를 반환하고, 실패 시 false를 반환합니다.
  static Future<bool> registerToken({
    required Session session,
    required int userId,
    required String token,
    String? deviceType,
  }) async {
    try {
      final now = DateTime.now().toUtc();

      // 기존 토큰 조회
      final existingToken = await FcmToken.db.findFirstRow(
        session,
        where: (t) => t.userId.equals(userId) & t.token.equals(token),
      );

      if (existingToken != null) {
        // 기존 토큰 업데이트
        await FcmToken.db.updateRow(
          session,
          existingToken.copyWith(
            deviceType: deviceType,
            updatedAt: now,
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
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      session.log(
        'FCM 토큰 등록/업데이트 성공: userId=$userId, token=${token.substring(0, 20)}...',
        level: LogLevel.info,
      );

      return true;
    } on Exception catch (e, stackTrace) {
      session.log(
        'FCM 토큰 등록/업데이트 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      return false;
    }
  }

  /// FCM 토큰 삭제
  ///
  /// [userId]는 사용자 ID입니다.
  /// [token]은 FCM 토큰입니다.
  ///
  /// 성공 시 true를 반환하고, 실패 시 false를 반환합니다.
  static Future<bool> deleteToken({
    required Session session,
    required int userId,
    required String token,
  }) async {
    try {
      await FcmToken.db.deleteWhere(
        session,
        where: (t) => t.userId.equals(userId) & t.token.equals(token),
      );

      session.log(
        'FCM 토큰 삭제 성공: userId=$userId, token=${token.substring(0, 20)}...',
        level: LogLevel.info,
      );

      return true;
    } on Exception catch (e, stackTrace) {
      session.log(
        'FCM 토큰 삭제 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      return false;
    }
  }

  /// 사용자의 모든 FCM 토큰 조회
  ///
  /// [userId]는 사용자 ID입니다.
  ///
  /// FCM 토큰 리스트를 반환합니다.
  static Future<List<String>> getTokensByUserId({
    required Session session,
    required int userId,
  }) async {
    try {
      final tokens = await FcmToken.db.find(
        session,
        where: (t) => t.userId.equals(userId),
      );

      return tokens.map((token) => token.token).toList();
    } on Exception catch (e, stackTrace) {
      session.log(
        'FCM 토큰 조회 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      return [];
    }
  }

  /// 채팅방 참여자들의 FCM 토큰 조회 (발신자 제외)
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [excludeUserId]는 제외할 사용자 ID입니다 (발신자).
  ///
  /// FCM 토큰 리스트를 반환합니다.
  static Future<List<String>> getTokensByChatRoomId({
    required Session session,
    required int chatRoomId,
    required int excludeUserId,
  }) async {
    try {
      // 채팅방 참여자 조회
      final participants = await ChatParticipant.db.find(
        session,
        where: (p) =>
            p.chatRoomId.equals(chatRoomId) &
            p.isActive.equals(true) &
            p.userId.notEquals(excludeUserId),
      );

      if (participants.isEmpty) {
        return [];
      }

      // 참여자들의 사용자 ID 추출
      final userIds = participants
          .map((p) => p.userId)
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (userIds.isEmpty) {
        return [];
      }

      // 각 사용자의 FCM 토큰 조회
      final allTokens = <String>[];
      for (final userId in userIds) {
        final tokens = await getTokensByUserId(
          session: session,
          userId: userId,
        );
        allTokens.addAll(tokens);
      }

      return allTokens;
    } on Exception catch (e, stackTrace) {
      session.log(
        '채팅방 참여자 FCM 토큰 조회 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      return [];
    }
  }
}
