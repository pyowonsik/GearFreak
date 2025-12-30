import 'dart:developer' as developer;
import 'package:gear_freak_server/src/common/fcm/service/fcm_service.dart';
import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 채팅 알림 서비스
/// 채팅방 알림 설정, 읽음 처리, 읽지 않은 메시지 개수, FCM 알림 전송 관련 비즈니스 로직을 처리합니다.
class ChatNotificationService {
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
          '채팅방을 찾을 수 없음: chatRoomId=$chatRoomId',
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
          '채팅방에 참여하지 않은 사용자: userId=$userId, chatRoomId=$chatRoomId',
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
        '✅ 채팅방 알림 설정 변경 완료: userId=$userId, chatRoomId=$chatRoomId, isNotificationEnabled=$isNotificationEnabled',
        level: LogLevel.info,
      );
    } on Exception catch (e, stackTrace) {
      session.log(
        '❌ 채팅방 알림 설정 변경 실패: $e',
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
          '채팅방을 찾을 수 없음: chatRoomId=$chatRoomId',
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
          '채팅방에 참여하지 않은 사용자: userId=$userId, chatRoomId=$chatRoomId',
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
        '✅ 채팅방 읽음 처리 완료: userId=$userId, chatRoomId=$chatRoomId',
        level: LogLevel.info,
      );
    } on Exception catch (e, stackTrace) {
      session.log(
        '❌ 채팅방 읽음 처리 실패: $e',
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

      // 2. 모든 메시지 조회 (자신이 보낸 메시지 제외를 위해)
      final allMessages = await ChatMessage.db.find(
        session,
        where: (message) => message.chatRoomId.equals(chatRoomId),
      );

      // 3. leftAt이 있으면 leftAt 이후 메시지만 카운트 (lastReadAt 무시)
      // 재참여한 경우 나가기 이전 메시지는 읽은 것으로 간주
      if (participant.leftAt != null) {
        final unreadCount = allMessages.where((message) {
          return message.senderId != userId &&
              message.createdAt != null &&
              message.createdAt!.isAfter(participant.leftAt!);
        }).length;
        return unreadCount;
      }

      // 4. leftAt이 없으면 기존 로직대로 lastReadAt 기준으로 계산
      // lastReadAt이 null이면 모든 메시지를 읽지 않은 것으로 간주 (자신이 보낸 메시지 제외)
      if (participant.lastReadAt == null) {
        final unreadCount =
            allMessages.where((message) => message.senderId != userId).length;
        return unreadCount;
      }

      // 5. lastReadAt 이후의 메시지 개수 계산 (자신이 보낸 메시지는 제외)
      final unreadCount = allMessages.where((message) {
        return message.senderId != userId &&
            message.createdAt != null &&
            message.createdAt!.isAfter(participant.lastReadAt!);
      }).length;

      return unreadCount;
    } on Exception catch (e, stackTrace) {
      session.log(
        '❌ 안 읽은 메시지 개수 계산 실패: $e',
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
        '❌ 전체 읽지 않은 채팅 개수 조회 실패: $e',
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
          '⚠️ FCM 알림 전송 건너뜀: 채팅방을 찾을 수 없음 (chatRoomId=$chatRoomId)',
        );
        return;
      }

      // 2. 채팅방 참여자별 FCM 토큰과 알림 설정 조회 (발신자 제외)
      safeLog('📱 FCM 알림 전송 시작: chatRoomId=$chatRoomId, senderId=$senderId');

      final tokensWithSettings =
          await FcmTokenService.getTokensByChatRoomIdWithNotificationSettings(
        session: session,
        chatRoomId: chatRoomId,
        excludeUserId: senderId,
      );

      if (tokensWithSettings.isEmpty) {
        safeLog(
            '⚠️ FCM 알림 전송 건너뜀: 채팅방 참여자의 FCM 토큰이 없음 (chatRoomId=$chatRoomId)');
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

      // 5. 알림 설정에 따라 토큰 분류
      final tokensWithNotification = <String>[];
      final tokensWithoutNotification = <String>[];

      for (final tokenMap in tokensWithSettings.values) {
        for (final entry in tokenMap.entries) {
          if (entry.value) {
            // 알림 활성화: notification 포함
            tokensWithNotification.add(entry.key);
          } else {
            // 알림 비활성화: data만 전송 (포그라운드에서 메시지 수신 가능)
            tokensWithoutNotification.add(entry.key);
          }
        }
      }

      // 6. FCM 알림 전송 (알림 설정에 따라 분기)
      final futures = <Future<int>>[];

      // 알림 활성화된 사용자에게는 notification 포함하여 전송
      if (tokensWithNotification.isNotEmpty) {
        futures.add(
          FcmService.sendNotifications(
            session: session,
            fcmTokens: tokensWithNotification,
            title: title,
            body: body,
            data: data,
            includeNotification: true,
          ),
        );
      }

      // 알림 비활성화된 사용자에게는 data만 전송 (포그라운드에서 메시지 수신 가능)
      if (tokensWithoutNotification.isNotEmpty) {
        futures.add(
          FcmService.sendNotifications(
            session: session,
            fcmTokens: tokensWithoutNotification,
            title: title,
            body: body,
            data: data,
            includeNotification: false,
          ),
        );
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }

      safeLog(
        '✅ FCM 알림 전송 완료: '
        'chatRoomId=$chatRoomId, '
        'senderId=$senderId, '
        'senderNickname="$senderNickname", '
        '알림ON=${tokensWithNotification.length}, '
        '알림OFF=${tokensWithoutNotification.length}, '
        'title="$title", '
        'body="$body"',
      );
    } on Exception catch (e, stackTrace) {
      // FCM 알림 전송 실패는 로그만 남기고 예외를 던지지 않음
      try {
        session.log(
          '❌ FCM 알림 전송 실패: $e',
          exception: e,
          stackTrace: stackTrace,
          level: LogLevel.warning,
        );
      } catch (_) {
        // Session이 닫혔으면 log 사용
        developer.log(
          '❌ FCM 알림 전송 실패: $e',
          name: 'ChatNotificationService',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }
}
