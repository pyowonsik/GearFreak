import 'dart:developer' as developer;

import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

import 'package:gear_freak_server/src/common/fcm/service/fcm_service.dart';

import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
import 'package:gear_freak_server/src/feature/notification/service/notification_service.dart';

/// 채팅 알림 서비스
/// 채팅방 알림 설정, 읽음 처리, 읽지 않은 메시지 개수, FCM 알림 전송 관련 비즈니스 로직을 처리합니다.
class ChatNotificationService {
  // ==================== Public Methods ====================

  /// 채팅방 알림 설정 변경
  /// 사용자가 특정 채팅방의 알림을 켜거나 끕니다.
  Future<void> updateChatRoomNotification(
    Session session,
    int userId,
    int chatRoomId,
    bool isNotificationEnabled,
  ) async {
    try {
      // 1. 채팅방 존재 확인
      final chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      if (chatRoom == null) {
        session.log(
          '[ChatNotificationService] updateChatRoomNotification - warning: chat room not found - chatRoomId=$chatRoomId',
          level: LogLevel.warning,
        );
        throw Exception('채팅방을 찾을 수 없습니다.');
      }

      // 2. 참여자 정보 조회
      final participant = await ChatParticipant.db.findFirstRow(
        session,
        where: (p) => p.chatRoomId.equals(chatRoomId) & p.userId.equals(userId),
      );

      if (participant == null) {
        session.log(
          '[ChatNotificationService] updateChatRoomNotification - warning: user not participant - userId=$userId, chatRoomId=$chatRoomId',
          level: LogLevel.warning,
        );
        throw Exception('채팅방에 참여하지 않은 사용자입니다.');
      }

      // 3. 알림 설정 업데이트
      final now = DateTime.now().toUtc();
      await ChatParticipant.db.updateRow(
        session,
        participant.copyWith(
          isNotificationEnabled: isNotificationEnabled,
          updatedAt: now,
        ),
      );

      session.log(
        '[ChatNotificationService] updateChatRoomNotification - success: userId=$userId, chatRoomId=$chatRoomId, isNotificationEnabled=$isNotificationEnabled',
        level: LogLevel.info,
      );
    } on Exception catch (e, stackTrace) {
      session.log(
        '[ChatNotificationService] updateChatRoomNotification - error: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 채팅방 읽음 처리
  /// 사용자가 채팅방의 모든 메시지를 읽음 처리합니다.
  Future<void> markChatRoomAsRead(
    Session session,
    int userId,
    int chatRoomId,
  ) async {
    try {
      // 1. 채팅방 존재 확인
      final chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      if (chatRoom == null) {
        session.log(
          '[ChatNotificationService] markChatRoomAsRead - warning: chat room not found - chatRoomId=$chatRoomId',
          level: LogLevel.warning,
        );
        return;
      }

      // 2. 참여자 정보 조회
      final participant = await ChatParticipant.db.findFirstRow(
        session,
        where: (p) =>
            p.chatRoomId.equals(chatRoomId) &
            p.userId.equals(userId) &
            p.isActive.equals(true),
      );

      if (participant == null) {
        session.log(
          '[ChatNotificationService] markChatRoomAsRead - warning: user not participant - userId=$userId, chatRoomId=$chatRoomId',
          level: LogLevel.warning,
        );
        return;
      }

      // 3. lastReadAt을 현재 시간으로 업데이트
      // leftAt이 있으면 null로 설정 (재참여 후 읽음 처리 시 leftAt 제거)
      final now = DateTime.now().toUtc();
      await ChatParticipant.db.updateRow(
        session,
        participant.copyWith(
          lastReadAt: now,
          leftAt: null, // 읽음 처리 시 leftAt 제거 (재참여 완료)
          updatedAt: now,
        ),
      );

      session.log(
        '[ChatNotificationService] markChatRoomAsRead - success: userId=$userId, chatRoomId=$chatRoomId',
        level: LogLevel.info,
      );
    } on Exception catch (e, stackTrace) {
      session.log(
        '[ChatNotificationService] markChatRoomAsRead - error: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 안 읽은 메시지 개수 계산
  /// 사용자가 특정 채팅방에서 읽지 않은 메시지 개수를 반환합니다.
  Future<int> getUnreadCount(
    Session session,
    int userId,
    int chatRoomId,
  ) async {
    try {
      // 1. 참여자 정보 조회
      final participant = await ChatParticipant.db.findFirstRow(
        session,
        where: (p) =>
            p.chatRoomId.equals(chatRoomId) &
            p.userId.equals(userId) &
            p.isActive.equals(true),
      );

      if (participant == null) {
        return 0;
      }

      // 2. DB COUNT 쿼리로 직접 계산 (메모리 필터링 대신)
      // Serverpod ORM 제약으로 DateTime 비교가 WHERE 절에서 지원되지 않으므로
      // 메모리 필터링을 최소화하는 방식으로 개선

      // 3. leftAt이 있으면 leftAt 이후 메시지만 카운트 (lastReadAt 무시)
      // 재참여한 경우 나가기 이전 메시지는 읽은 것으로 간주
      if (participant.leftAt != null) {
        final messages = await ChatMessage.db.find(
          session,
          where: (msg) =>
              msg.chatRoomId.equals(chatRoomId) &
              msg.senderId.notEquals(userId),
        );
        final unreadCount = messages
            .where((msg) =>
                msg.createdAt != null &&
                msg.createdAt!.isAfter(participant.leftAt!))
            .length;
        return unreadCount;
      }

      // 4. leftAt이 없으면 기존 로직대로 lastReadAt 기준으로 계산
      // lastReadAt이 null이면 모든 메시지를 읽지 않은 것으로 간주 (자신이 보낸 메시지 제외)
      if (participant.lastReadAt == null) {
        final unreadCount = await ChatMessage.db.count(
          session,
          where: (msg) =>
              msg.chatRoomId.equals(chatRoomId) &
              msg.senderId.notEquals(userId),
        );
        return unreadCount;
      }

      // 5. lastReadAt 이후의 메시지 개수 계산 (자신이 보낸 메시지는 제외)
      final messages = await ChatMessage.db.find(
        session,
        where: (msg) =>
            msg.chatRoomId.equals(chatRoomId) &
            msg.senderId.notEquals(userId),
      );
      final unreadCount = messages
          .where((msg) =>
              msg.createdAt != null &&
              msg.createdAt!.isAfter(participant.lastReadAt!))
          .length;

      return unreadCount;
    } on Exception catch (e, stackTrace) {
      session.log(
        '[ChatNotificationService] getUnreadCount - error: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }

  /// 전체 채팅방의 읽지 않은 메시지 총합 조회
  /// 사용자가 참여 중인 모든 채팅방에서 읽지 않은 메시지 개수의 합을 반환합니다.
  Future<int> getTotalUnreadChatCount(
    Session session,
    int userId,
  ) async {
    try {
      // 1. 사용자가 참여 중인 모든 채팅방 조회
      final participants = await ChatParticipant.db.find(
        session,
        where: (p) => p.userId.equals(userId) & p.isActive.equals(true),
      );

      if (participants.isEmpty) {
        return 0;
      }

      // 2. 각 채팅방별로 읽지 않은 메시지 개수 계산하여 합산
      int totalUnreadCount = 0;
      for (final participant in participants) {
        final unreadCount = await getUnreadCount(
          session,
          userId,
          participant.chatRoomId,
        );
        totalUnreadCount += unreadCount;
      }

      return totalUnreadCount;
    } on Exception catch (e, stackTrace) {
      session.log(
        '[ChatNotificationService] getTotalUnreadChatCount - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      return 0;
    }
  }

  /// FCM 알림 전송 (비동기)
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [senderId]는 발신자 ID입니다.
  /// [senderNickname]은 발신자 닉네임입니다.
  /// [message]는 전송된 메시지입니다.
  ///
  /// 비동기로 실행되며, 실패해도 메시지 전송에는 영향을 주지 않습니다.
  /// Session이 닫힌 후에도 실행될 수 있으므로 Session 로깅은 안전하게 처리합니다.
  Future<void> sendFcmNotification({
    required Session session,
    required int chatRoomId,
    required int senderId,
    String? senderNickname,
    required ChatMessageResponseDto message,
  }) async {
    // Session이 닫힌 후에도 실행될 수 있으므로 안전한 로깅 헬퍼
    void safeLog(String message, {LogLevel level = LogLevel.info}) {
      try {
        session.log(message, level: level);
      } catch (e) {
        // Session이 닫혔으면 log 사용
        developer.log(message, name: 'ChatNotificationService');
      }
    }

    try {
      // 1. 채팅방 정보 조회 (productId 가져오기)
      final chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      if (chatRoom == null) {
        safeLog(
          '[ChatNotificationService] sendFcmNotification - skip: chat room not found - chatRoomId=$chatRoomId',
        );
        return;
      }

      // 2. 채팅방 참여자별 FCM 토큰과 알림 설정 조회 (발신자 제외)
      safeLog('[ChatNotificationService] sendFcmNotification - start: chatRoomId=$chatRoomId, senderId=$senderId');

      final tokensWithSettings =
          await FcmTokenService.getTokensByChatRoomIdWithNotificationSettings(
        session: session,
        chatRoomId: chatRoomId,
        excludeUserId: senderId,
      );

      if (tokensWithSettings.isEmpty) {
        safeLog(
            '[ChatNotificationService] sendFcmNotification - skip: no FCM tokens for participants - chatRoomId=$chatRoomId');
        return;
      }

      // 3. 알림 제목 및 본문 생성
      final title = senderNickname ?? '알 수 없음';
      String body = message.content;

      // 메시지 타입에 따라 본문 변경
      switch (message.messageType) {
        case MessageType.image:
          body = '사진을 보냈습니다';
          break;
        case MessageType.file:
          body = '파일을 보냈습니다';
          break;
        case MessageType.text:
        default:
          // 텍스트 메시지는 내용을 그대로 사용 (너무 길면 자르기)
          if (body.length > 50) {
            body = '${body.substring(0, 50)}...';
          }
          break;
      }

      // 4. 추가 데이터 설정 (딥링크를 위해 productId 포함)
      final data = {
        'type': 'chat_message',
        'chatRoomId': chatRoomId.toString(),
        'productId': chatRoom.productId.toString(),
        'messageId': message.id.toString(),
        'senderId': senderId.toString(),
      };

      // 5. 사용자별로 badge 계산 후 FCM 알림 전송
      // (badge가 사용자마다 다르므로 사용자별로 전송)
      int notificationOnCount = 0;
      int notificationOffCount = 0;

      for (final entry in tokensWithSettings.entries) {
        final recipientUserId = entry.key;
        final tokenMap = entry.value;

        // 알림 활성화된 토큰과 비활성화된 토큰 분류
        final enabledTokens = <String>[];
        final disabledTokens = <String>[];

        for (final tokenEntry in tokenMap.entries) {
          if (tokenEntry.value) {
            enabledTokens.add(tokenEntry.key);
          } else {
            disabledTokens.add(tokenEntry.key);
          }
        }

        // 알림 활성화된 토큰에 notification 포함하여 전송 (badge 포함)
        if (enabledTokens.isNotEmpty) {
          // 해당 사용자의 읽지 않은 총 개수 계산 (채팅 + 알림)
          final unreadChatCount = await getTotalUnreadChatCount(
            session,
            recipientUserId,
          );
          final unreadNotificationCount =
              await NotificationService.getUnreadCount(
            session: session,
            userId: recipientUserId,
          );
          final totalBadge = unreadChatCount + unreadNotificationCount;

          await FcmService.sendNotifications(
            session: session,
            fcmTokens: enabledTokens,
            title: title,
            body: body,
            data: data,
            includeNotification: true,
            badge: totalBadge,
          );
          notificationOnCount += enabledTokens.length;
        }

        // 알림 비활성화된 토큰에 data만 전송 (badge 없음)
        if (disabledTokens.isNotEmpty) {
          await FcmService.sendNotifications(
            session: session,
            fcmTokens: disabledTokens,
            title: title,
            body: body,
            data: data,
            includeNotification: false,
          );
          notificationOffCount += disabledTokens.length;
        }
      }

      safeLog(
        '[ChatNotificationService] sendFcmNotification - success: '
        'chatRoomId=$chatRoomId, '
        'senderId=$senderId, '
        'senderNickname="$senderNickname", '
        'notificationOn=$notificationOnCount, '
        'notificationOff=$notificationOffCount, '
        'title="$title", '
        'body="$body"',
      );
    } on Exception catch (e, stackTrace) {
      // FCM 알림 전송 실패는 로그만 남기고 예외를 던지지 않음
      try {
        session.log(
          '[ChatNotificationService] sendFcmNotification - warning: $e',
          exception: e,
          stackTrace: stackTrace,
          level: LogLevel.warning,
        );
      } catch (_) {
        // Session이 닫혔으면 developer.log 사용
        developer.log(
          '[ChatNotificationService] sendFcmNotification - warning: $e',
          name: 'ChatNotificationService',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }
}
