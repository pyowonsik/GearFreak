import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

/// FCM 토큰 서비스
/// FCM 토큰 관련 비즈니스 로직을 처리합니다.
class FcmTokenService {
  // ==================== Public Methods ====================

  /// FCM 토큰 등록 또는 업데이트
  ///
  /// 기존 토큰이 있으면 업데이트하고, 없으면 새로 등록합니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 사용자 ID
  /// [token]: FCM 토큰
  /// [deviceType]: 디바이스 타입 (ios, android)
  /// Returns: true = 성공, false = 실패
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
  /// [session]: Serverpod 세션
  /// [userId]: 사용자 ID
  /// [token]: 삭제할 FCM 토큰
  /// Returns: true = 성공, false = 실패
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
  /// [session]: Serverpod 세션
  /// [userId]: 사용자 ID
  /// Returns: FCM 토큰 목록
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
  /// [session]: Serverpod 세션
  /// [chatRoomId]: 채팅방 ID
  /// [excludeUserId]: 제외할 사용자 ID (발신자)
  /// Returns: FCM 토큰 목록
  static Future<List<String>> getTokensByChatRoomId({
    required Session session,
    required int chatRoomId,
    required int excludeUserId,
  }) async {
    try {
      // 채팅방 참여자 조회 (모든 활성 참여자, 알림 설정 무관)
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
      final userIds = participants.map((p) => p.userId).toList();

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

  /// 채팅방 참여자별 FCM 토큰과 알림 설정 조회 (발신자 제외)
  ///
  /// 비활성 참여자도 포함하여 재활성화 시 메시지를 받을 수 있도록 합니다.
  ///
  /// [session]: Serverpod 세션
  /// [chatRoomId]: 채팅방 ID
  /// [excludeUserId]: 제외할 사용자 ID (발신자)
  /// Returns: Map<userId, Map<token, isNotificationEnabled>>
  static Future<Map<int, Map<String, bool>>>
      getTokensByChatRoomIdWithNotificationSettings({
    required Session session,
    required int chatRoomId,
    required int excludeUserId,
  }) async {
    try {
      // 채팅방 참여자 조회 (활성 + 비활성 참여자 모두 포함)
      // 비활성 참여자도 재활성화 후 메시지를 받을 수 있도록 FCM 전송
      final participants = await ChatParticipant.db.find(
        session,
        where: (p) =>
            p.chatRoomId.equals(chatRoomId) &
            p.userId.notEquals(excludeUserId),
      );

      if (participants.isEmpty) {
        return {};
      }

      // 참여자별 토큰과 알림 설정 매핑
      final result = <int, Map<String, bool>>{};
      for (final participant in participants) {
        final userId = participant.userId;

        final tokens = await getTokensByUserId(
          session: session,
          userId: userId,
        );

        if (tokens.isEmpty) continue;

        // 각 토큰에 대해 알림 설정 매핑
        final tokenMap = <String, bool>{};
        for (final token in tokens) {
          tokenMap[token] = participant.isNotificationEnabled;
        }

        result[userId] = tokenMap;
      }

      return result;
    } on Exception catch (e, stackTrace) {
      session.log(
        '채팅방 참여자 FCM 토큰 및 알림 설정 조회 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      return {};
    }
  }
}
