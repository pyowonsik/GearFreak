import 'dart:developer' as developer;

import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

import 'package:gear_freak_server/src/common/s3/service/s3_service.dart';
import 'package:gear_freak_server/src/common/s3/util/s3_util.dart';

import 'package:gear_freak_server/src/feature/chat/service/chat_notification_service.dart';
import 'package:gear_freak_server/src/feature/chat/service/chat_room_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';

/// 채팅 메시지 서비스
/// 메시지 전송, 조회 관련 비즈니스 로직을 처리합니다.
class ChatMessageService {
  final ChatRoomService _chatRoomService = ChatRoomService();
  final ChatNotificationService _notificationService =
      ChatNotificationService();

  // ==================== Public Methods ====================

  /// 메시지 전송
  ///
  /// 카카오톡/당근마켓 방식으로 첫 메시지 전송 시 채팅방을 자동 생성합니다.
  /// 채팅방 나가기 후 재참여 시 leftAt 이후 메시지만 보이도록 처리합니다.
  /// 메시지 전송 후 Redis를 통해 글로벌 브로드캐스팅하고 FCM 알림을 전송합니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 발신자 ID
  /// [request]: 메시지 전송 요청 DTO
  /// Returns: 전송된 메시지 응답 DTO
  /// Throws: Exception - 채팅방 생성 실패, 참여자 아님, 메시지 비어있음
  Future<ChatMessageResponseDto> sendMessage(
    Session session,
    int userId,
    SendMessageRequestDto request,
  ) async {
    try {
      int chatRoomId;
      ChatRoom? chatRoom;

      // 1. 채팅방이 없으면 생성 (카카오톡/당근마켓 방식)
      if (request.chatRoomId == null || request.chatRoomId == 0) {
        // productId와 targetUserId가 필수
        if (request.productId == null || request.targetUserId == null) {
          throw Exception('채팅방이 없을 경우 상품 ID와 상대방 사용자 ID가 필요합니다.');
        }

        // 채팅방 생성 또는 조회
        final createResult = await _chatRoomService.createOrGetChatRoom(
          session,
          userId,
          CreateChatRoomRequestDto(
            productId: request.productId!,
            targetUserId: request.targetUserId,
          ),
        );

        if (!createResult.success || createResult.chatRoomId == null) {
          throw Exception(createResult.message ?? '채팅방 생성에 실패했습니다.');
        }

        chatRoomId = createResult.chatRoomId!;
        chatRoom = createResult.chatRoom;

        // 상대방 참여자 추가 (메시지 전송 시 두 명 모두 참여자로 추가)
        await _chatRoomService.addParticipant(
          session,
          chatRoomId,
          request.targetUserId!,
        );

        // 참여자 수 업데이트
        await _chatRoomService.updateParticipantCount(session, chatRoomId);

        // 업데이트된 채팅방 정보 조회
        chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      } else {
        chatRoomId = request.chatRoomId!;

        // 채팅방 참여 확인 (isActive 여부와 관계없이 조회)
        final participation = await ChatParticipant.db.findFirstRow(
          session,
          where: (participant) =>
              participant.userId.equals(userId) &
              participant.chatRoomId.equals(chatRoomId),
        );

        if (participation == null) {
          throw Exception('채팅방에 참여하지 않은 사용자입니다.');
        }

        // 발신자가 비활성 상태인 경우 재활성화
        // leftAt은 유지하여 재참여 후 leftAt 이후 메시지만 보이도록 함
        if (!participation.isActive) {
          final now = DateTime.now().toUtc();
          final previousLeftAt = participation.leftAt; // 이전 leftAt 값 유지
          await ChatParticipant.db.updateRow(
            session,
            participation.copyWith(
              isActive: true,
              joinedAt: now,
              leftAt: previousLeftAt, // leftAt 유지 (재참여 후 필터링 기준)
              updatedAt: now,
            ),
          );
          session.log(
            '[ChatMessageService] sendMessage - info: chat room rejoin - chatRoomId=$chatRoomId, userId=$userId, previousLeftAt=$previousLeftAt',
            level: LogLevel.info,
          );
        }

        // 채팅방의 다른 참여자들 중 비활성 상태인 참여자들 재활성화
        // (상대방이 메시지를 보내면 내 채팅방에 다시 나타나도록)
        // leftAt은 유지하여 재참여 후 leftAt 이후 메시지만 보이도록 함
        final inactiveParticipants = await ChatParticipant.db.find(
          session,
          where: (participant) =>
              participant.chatRoomId.equals(chatRoomId) &
              participant.userId.notEquals(userId) &
              participant.isActive.equals(false),
        );

        if (inactiveParticipants.isNotEmpty) {
          final now = DateTime.now().toUtc();
          for (final participant in inactiveParticipants) {
            final previousLeftAt = participant.leftAt; // 이전 leftAt 값 유지
            await ChatParticipant.db.updateRow(
              session,
              participant.copyWith(
                isActive: true,
                joinedAt: now,
                leftAt: previousLeftAt, // leftAt 유지 (재참여 후 필터링 기준)
                updatedAt: now,
              ),
            );
          }
          session.log(
            '[ChatMessageService] sendMessage - info: participants reactivated - chatRoomId=$chatRoomId, reactivatedCount=${inactiveParticipants.length}',
            level: LogLevel.info,
          );
        }

        // 참여자 수 업데이트
        await _chatRoomService.updateParticipantCount(session, chatRoomId);

        // 채팅방 정보 조회
        chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      }

      // 2. 메시지 내용 검증
      if (request.content.trim().isEmpty) {
        throw Exception('메시지 내용이 비어있습니다.');
      }

      // 3. DB에 메시지 저장
      final now = DateTime.now().toUtc();
      final message = ChatMessage(
        chatRoomId: chatRoomId,
        senderId: userId,
        content: request.content,
        messageType: request.messageType,
        attachmentUrl: request.attachmentUrl,
        attachmentName: request.attachmentName,
        attachmentSize: request.attachmentSize,
        createdAt: now,
        updatedAt: now,
      );

      final savedMessage = await ChatMessage.db.insertRow(session, message);

      // 4. 채팅방 최근 활동 시간 업데이트
      if (chatRoom != null) {
        await ChatRoom.db.updateRow(
          session,
          chatRoom.copyWith(
            lastActivityAt: now,
            updatedAt: now,
          ),
        );
      }

      // 5. 발신자 정보 조회
      final user = await User.db.findById(session, userId);

      // 6. Private 버킷 이미지/파일인 경우 Presigned URL로 변환
      String? attachmentUrl = savedMessage.attachmentUrl;
      String content = savedMessage.content;

      // attachmentUrl이 Private 버킷인 경우 Presigned URL로 변환
      if (attachmentUrl != null &&
          (savedMessage.messageType == MessageType.image ||
              savedMessage.messageType == MessageType.file)) {
        try {
          // URL에서 파일 키 추출
          final fileKey = S3Util.extractKeyFromUrl(attachmentUrl);
          // chatRoom 경로인 경우 Private 버킷이므로 Presigned URL 생성
          if (fileKey.startsWith('chatRoom/')) {
            attachmentUrl = await S3Service.generatePresignedDownloadUrl(
              session,
              fileKey,
            );
          }
        } catch (e) {
          // Presigned URL 생성 실패 시 원본 URL 유지
          session.log(
            '[ChatMessageService] sendMessage - warning: Presigned URL generation failed (attachmentUrl) - $e',
            level: LogLevel.warning,
          );
        }
      }

      // content가 URL 형식이고 Private 버킷인 경우 Presigned URL로 변환 (동영상 썸네일)
      if (savedMessage.messageType == MessageType.file &&
          (content.startsWith('http://') || content.startsWith('https://'))) {
        try {
          // URL에서 파일 키 추출
          final fileKey = S3Util.extractKeyFromUrl(content);
          // chatRoom 경로인 경우 Private 버킷이므로 Presigned URL 생성
          if (fileKey.startsWith('chatRoom/')) {
            content = await S3Service.generatePresignedDownloadUrl(
              session,
              fileKey,
            );
          }
        } catch (e) {
          // Presigned URL 생성 실패 시 원본 URL 유지
          session.log(
            '[ChatMessageService] sendMessage - warning: Presigned URL generation failed (content/thumbnail) - $e',
            level: LogLevel.warning,
          );
        }
      }

      // 7. 응답 DTO 생성
      final response = ChatMessageResponseDto(
        id: savedMessage.id!,
        chatRoomId: savedMessage.chatRoomId,
        senderId: savedMessage.senderId,
        senderNickname: user?.nickname,
        content: content,
        messageType: savedMessage.messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: savedMessage.attachmentName,
        attachmentSize: savedMessage.attachmentSize,
        createdAt: savedMessage.createdAt ?? now,
        updatedAt: savedMessage.updatedAt,
      );

      // 8. Redis 기반 글로벌 브로드캐스팅
      await session.messages.postMessage(
        'chat_room_$chatRoomId',
        response,
        global: true, // Redis를 통한 글로벌 브로드캐스팅
      );

      // 9. FCM 알림 전송 (비동기, 실패해도 메시지 전송은 성공)
      // Session이 닫힌 후에도 실행될 수 있으므로 unawaited로 실행
      await _notificationService
          .sendFcmNotification(
        session: session,
        chatRoomId: chatRoomId,
        senderId: userId,
        senderNickname: user?.nickname,
        message: response,
      )
          .catchError((error) {
        // Session이 닫힌 후에는 로깅할 수 없으므로 developer.log 사용
        developer.log(
          '[ChatMessageService] sendFcmNotification - warning: FCM notification failed (ignored) - $error',
          name: 'ChatMessageService',
          error: error,
        );
      });

      session.log(
        '[ChatMessageService] sendMessage - success: '
        'chatRoomId=$chatRoomId, '
        'senderId=$userId, '
        'messageId=${savedMessage.id}',
        level: LogLevel.info,
      );

      return response;
    } on Exception catch (e, stackTrace) {
      session.log(
        '[ChatMessageService] sendMessage - error: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 페이지네이션된 메시지 조회
  ///
  /// 채팅방의 메시지를 최신순으로 조회합니다.
  /// 재참여 사용자의 경우 leftAt 이후 메시지만 반환합니다.
  /// Private 버킷의 첨부파일은 Presigned URL로 변환합니다.
  ///
  /// [session]: Serverpod 세션
  /// [request]: 메시지 조회 요청 DTO (페이지, 개수, 타입 필터)
  /// Returns: 페이지네이션된 메시지 목록
  /// Throws: Exception - 채팅방 없음, 잘못된 페이지네이션 값
  Future<PaginatedChatMessagesResponseDto> getChatMessagesPaginated(
    Session session,
    GetChatMessagesRequestDto request,
  ) async {
    try {
      // 입력 검증
      if (request.page < 1) {
        throw Exception('페이지 번호는 1 이상이어야 합니다.');
      }
      if (request.limit < 1 || request.limit > 100) {
        throw Exception('페이지 크기는 1~100 사이여야 합니다.');
      }

      // 채팅방 존재 여부 확인
      final chatRoom = await ChatRoom.db.findById(
        session,
        request.chatRoomId,
      );
      if (chatRoom == null) {
        throw Exception('채팅방을 찾을 수 없습니다.');
      }

      // 현재 사용자 정보 조회
      final user = await UserService.getMe(session);
      if (user.id == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // 현재 사용자의 채팅방 참여 정보 조회 (leftAt 확인용)
      final participation = await ChatParticipant.db.findFirstRow(
        session,
        where: (p) =>
            p.chatRoomId.equals(request.chatRoomId) & p.userId.equals(user.id!),
      );

      // leftAt 이후 메시지만 필터링하기 위한 기준 시각
      // 재참여 시 leftAt을 유지하므로, leftAt이 있으면 재참여 전에 나간 시점 이후 메시지만 보여야 함
      DateTime? leftAtFilter;
      if (participation != null && participation.leftAt != null) {
        leftAtFilter = participation.leftAt;
      }

      // 오프셋 계산
      final offset = (request.page - 1) * request.limit;

      // 메시지 조회 (최신 순으로 정렬)
      // Serverpod ORM 제약: DateTime 비교(greaterThan 등)가 WHERE 절에서 지원되지 않음
      // 따라서 leftAt 필터는 메모리에서 적용 후 페이지네이션 처리
      // 참고: lib/src/feature/chat/service/chat_notification_service.dart의 getUnreadCount 참조
      final allMessages = await ChatMessage.db.find(
        session,
        orderBy: (message) => message.createdAt,
        orderDescending: true,
        where: (message) {
          var condition = message.chatRoomId.equals(request.chatRoomId);
          // 선택적 타입 필터 적용
          if (request.messageType != null) {
            condition =
                condition & message.messageType.equals(request.messageType);
          }
          return condition;
        },
      );

      // leftAt 이후 메시지만 필터링 (메모리에서 필터링)
      // Serverpod ORM이 DateTime 비교를 WHERE 절에서 지원하지 않으므로 불가피
      final filteredMessages = leftAtFilter != null
          ? allMessages.where((msg) {
              return msg.createdAt != null &&
                  msg.createdAt!.isAfter(leftAtFilter!);
            }).toList()
          : allMessages;

      // 페이지네이션 적용
      final messages =
          filteredMessages.skip(offset).take(request.limit).toList();

      // 필터가 적용된 경우, 페이지네이션 기준 카운트도 필터 기준으로 계산
      var effectiveTotalCount = filteredMessages.length;

      // ChatMessageResponseDto 리스트 생성
      final messageResponses = <ChatMessageResponseDto>[];
      for (final message in messages) {
        // 발신자 정보 조회
        final user = await User.db.findById(session, message.senderId);

        // Private 버킷 이미지/파일인 경우 Presigned URL로 변환
        String? attachmentUrl = message.attachmentUrl;
        String content = message.content;

        // attachmentUrl이 Private 버킷인 경우 Presigned URL로 변환
        if (attachmentUrl != null &&
            (message.messageType == MessageType.image ||
                message.messageType == MessageType.file)) {
          try {
            // URL에서 파일 키 추출
            final fileKey = S3Util.extractKeyFromUrl(attachmentUrl);
            // chatRoom 경로인 경우 Private 버킷이므로 Presigned URL 생성
            if (fileKey.startsWith('chatRoom/')) {
              attachmentUrl = await S3Service.generatePresignedDownloadUrl(
                session,
                fileKey,
              );
            }
          } catch (e) {
            // Presigned URL 생성 실패 시 원본 URL 유지
            session.log(
              '[ChatMessageService] getChatMessagesPaginated - warning: Presigned URL generation failed (attachmentUrl) - $e',
              level: LogLevel.warning,
            );
          }
        }

        // content가 URL 형식이고 Private 버킷인 경우 Presigned URL로 변환 (동영상 썸네일)
        if (message.messageType == MessageType.file &&
            (content.startsWith('http://') || content.startsWith('https://'))) {
          try {
            // URL에서 파일 키 추출
            final fileKey = S3Util.extractKeyFromUrl(content);
            // chatRoom 경로인 경우 Private 버킷이므로 Presigned URL 생성
            if (fileKey.startsWith('chatRoom/')) {
              content = await S3Service.generatePresignedDownloadUrl(
                session,
                fileKey,
              );
            }
          } catch (e) {
            // Presigned URL 생성 실패 시 원본 URL 유지
            session.log(
              '[ChatMessageService] getChatMessagesPaginated - warning: Presigned URL generation failed (content/thumbnail) - $e',
              level: LogLevel.warning,
            );
          }
        }

        final response = ChatMessageResponseDto(
          id: message.id!,
          chatRoomId: message.chatRoomId,
          senderId: message.senderId,
          senderNickname: user?.nickname,
          content: content,
          messageType: message.messageType,
          attachmentUrl: attachmentUrl,
          attachmentName: message.attachmentName,
          attachmentSize: message.attachmentSize,
          createdAt: message.createdAt ?? DateTime.now().toUtc(),
          updatedAt: message.updatedAt,
        );
        messageResponses.add(response);
      }

      // 페이지네이션 결과 생성
      final hasMore = offset + request.limit < effectiveTotalCount;

      return PaginatedChatMessagesResponseDto(
        pagination: PaginationDto(
          page: request.page,
          limit: request.limit,
          totalCount: effectiveTotalCount,
          hasMore: hasMore,
        ),
        messages: messageResponses,
      );
    } on Exception catch (e, stackTrace) {
      session.log(
        '[ChatMessageService] getChatMessagesPaginated - error: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 채팅방의 마지막 메시지 조회
  ///
  /// 채팅방 목록에서 마지막 메시지 미리보기용으로 사용됩니다.
  ///
  /// [session]: Serverpod 세션
  /// [chatRoomId]: 채팅방 ID
  /// Returns: 마지막 메시지 (없으면 null)
  Future<ChatMessage?> getLastMessageByChatRoomId(
    Session session,
    int chatRoomId,
  ) async {
    try {
      // 채팅방 존재 여부 확인
      final chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      if (chatRoom == null) {
        session.log(
          '[ChatMessageService] getLastMessageByChatRoomId - warning: chat room not found - chatRoomId=$chatRoomId',
          level: LogLevel.warning,
        );
        return null;
      }

      // 해당 채팅방의 마지막 메시지 조회 (최신)
      final lastMessage = await ChatMessage.db.findFirstRow(
        session,
        orderBy: (message) => message.createdAt,
        orderDescending: true,
        where: (message) => message.chatRoomId.equals(chatRoomId),
      );

      if (lastMessage == null) {
        session.log(
          '[ChatMessageService] getLastMessageByChatRoomId - info: no messages in chat room - chatRoomId=$chatRoomId',
          level: LogLevel.info,
        );
        return null;
      }

      return lastMessage;
    } on Exception catch (e, stackTrace) {
      session.log(
        '[ChatMessageService] getLastMessageByChatRoomId - error: $e - chatRoomId=$chatRoomId',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
