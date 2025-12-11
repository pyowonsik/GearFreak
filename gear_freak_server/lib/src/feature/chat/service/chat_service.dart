import 'package:gear_freak_server/src/common/s3/service/s3_service.dart';
import 'package:gear_freak_server/src/common/s3/util/s3_util.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 채팅 서비스
/// 채팅방 및 메시지 관련 비즈니스 로직을 처리합니다.
class ChatService {
  // ==================== Public Methods (Endpoint에서 직접 호출) ====================

  /// 채팅방 생성 또는 조회
  /// 상품 ID와 상대방 사용자 ID로 기존 채팅방을 찾거나 새로 생성합니다.
  Future<CreateChatRoomResponseDto> createOrGetChatRoom(
    Session session,
    int userId,
    CreateChatRoomRequestDto request,
  ) async {
    try {
      session.log(
        '💬 채팅방 생성/조회 시작 - '
        'userId: $userId, '
        'productId: ${request.productId}, '
        'targetUserId: ${request.targetUserId}',
        level: LogLevel.info,
      );

      // 1. 상품 존재 확인
      final product = await Product.db.findById(session, request.productId);
      if (product == null) {
        return CreateChatRoomResponseDto(
          success: false,
          chatRoomId: null,
          chatRoom: null,
          message: '상품을 찾을 수 없습니다.',
        );
      }

      // 2. 사용자 ID 확인
      if (userId <= 0) {
        return CreateChatRoomResponseDto(
          success: false,
          chatRoomId: null,
          chatRoom: null,
          message: '유효하지 않은 사용자 ID입니다.',
        );
      }

      // 3. targetUserId가 없으면 상품의 sellerId를 사용
      int? targetUserId = request.targetUserId;
      if (targetUserId == null) {
        // 상품의 판매자 ID를 targetUserId로 사용
        targetUserId = product.sellerId;

        // 현재 사용자가 판매자인 경우 채팅방 생성 불가
        if (targetUserId == userId) {
          return CreateChatRoomResponseDto(
            success: false,
            chatRoomId: null,
            chatRoom: null,
            message: '본인이 등록한 상품에는 채팅할 수 없습니다.',
          );
        }
      }

      // 4. 상대방 사용자 확인
      final targetUser = await User.db.findById(session, targetUserId);
      if (targetUser == null) {
        return CreateChatRoomResponseDto(
          success: false,
          chatRoomId: null,
          chatRoom: null,
          message: '상대방 사용자를 찾을 수 없습니다.',
        );
      }

      // 5. 기존 채팅방 찾기 (1:1 채팅의 경우)
      // 현재 사용자와 상대방이 모두 참여한 채팅방 찾기
      final existingChatRoom = await _findExistingDirectChatRoom(
        session,
        request.productId,
        userId,
        targetUserId,
      );

      if (existingChatRoom != null) {
        session.log(
          '✅ 기존 채팅방 발견 - chatRoomId: ${existingChatRoom.id}',
          level: LogLevel.info,
        );
        return CreateChatRoomResponseDto(
          success: true,
          chatRoomId: existingChatRoom.id,
          chatRoom: existingChatRoom,
          message: '기존 채팅방을 찾았습니다.',
        );
      }

      // 6. 새 채팅방 생성
      final now = DateTime.now().toUtc();
      final chatRoom = ChatRoom(
        productId: request.productId,
        title: null, // 1:1 채팅방은 제목 없음
        chatRoomType: ChatRoomType.direct, // 기본값: 1:1 채팅
        participantCount: 0,
        lastActivityAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final createdChatRoom = await ChatRoom.db.insertRow(session, chatRoom);
      session.log(
        '✅ 채팅방 생성 완료 - chatRoomId: ${createdChatRoom.id}',
        level: LogLevel.info,
      );

      // 7. 참여자 추가 (현재 사용자만 추가, 상대방은 메시지 전송 시 추가)
      final chatRoomId = createdChatRoom.id;
      if (chatRoomId == null) {
        return CreateChatRoomResponseDto(
          success: false,
          chatRoomId: null,
          chatRoom: null,
          message: '채팅방 생성에 실패했습니다.',
        );
      }

      await _addParticipant(
        session,
        chatRoomId,
        userId,
      );

      // 8. 참여자 수 업데이트
      await _updateParticipantCount(session, chatRoomId);

      // 10. 업데이트된 채팅방 정보 조회
      final updatedChatRoom = await ChatRoom.db.findById(
        session,
        createdChatRoom.id!,
      );

      return CreateChatRoomResponseDto(
        success: true,
        chatRoomId: updatedChatRoom?.id,
        chatRoom: updatedChatRoom,
        message: '채팅방이 성공적으로 생성되었습니다.',
      );
    } on Exception catch (e, stackTrace) {
      session.log(
        '❌ 채팅방 생성/조회 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      return CreateChatRoomResponseDto(
        success: false,
        chatRoomId: null,
        chatRoom: null,
        message: '채팅방 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 채팅방 정보 조회
  Future<ChatRoom?> getChatRoomById(
    Session session,
    int chatRoomId,
  ) async {
    try {
      final chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      return chatRoom;
    } on Exception catch (e, stackTrace) {
      session.log(
        '❌ 채팅방 조회 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 상품 ID로 채팅방 목록 조회
  Future<List<ChatRoom>?> getChatRoomsByProductId(
    Session session,
    int productId,
  ) async {
    try {
      final chatRooms = await ChatRoom.db.find(
        session,
        where: (chatRoom) => chatRoom.productId.equals(productId),
      );
      return chatRooms;
    } on Exception catch (e, stackTrace) {
      session.log(
        '❌ 채팅방 목록 조회 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 사용자가 참여한 채팅방 목록 조회 (상품 ID 기준, 페이지네이션)
  Future<PaginatedChatRoomsResponseDto> getUserChatRoomsByProductId(
    Session session,
    int userId,
    int productId,
    PaginationDto pagination,
  ) async {
    try {
      final offset = (pagination.page - 1) * pagination.limit;

      // 사용자가 참여 중인 채팅방만 조회
      final participantChatRooms = await ChatParticipant.db.find(
        session,
        where: (participant) =>
            participant.userId.equals(userId) &
            participant.isActive.equals(true),
      );

      // 참여 중인 채팅방 ID 목록 추출
      final chatRoomIds = participantChatRooms
          .map((participant) => participant.chatRoomId)
          .toSet();

      if (chatRoomIds.isEmpty) {
        return _buildChatRoomsPaginationResponse([], 0, pagination);
      }

      // 전체 개수 조회
      final totalCount = await ChatRoom.db.count(
        session,
        where: (chatRoom) =>
            chatRoom.productId.equals(productId) &
            chatRoom.id.inSet(chatRoomIds),
      );

      // 해당 productId이면서 참여 중인 채팅방들만 조회 (페이지네이션 적용)
      final chatRooms = await ChatRoom.db.find(
        session,
        where: (chatRoom) =>
            chatRoom.productId.equals(productId) &
            chatRoom.id.inSet(chatRoomIds),
        orderBy: (chatRoom) => chatRoom.lastActivityAt,
        orderDescending: true,
        limit: pagination.limit,
        offset: offset,
      );

      return _buildChatRoomsPaginationResponse(
          chatRooms, totalCount, pagination);
    } on Exception catch (e, stackTrace) {
      session.log(
        '❌ 사용자 채팅방 목록 조회 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 사용자가 참여한 모든 채팅방 목록 조회 (페이지네이션)
  Future<PaginatedChatRoomsResponseDto> getMyChatRooms(
    Session session,
    int userId,
    PaginationDto pagination,
  ) async {
    try {
      final offset = (pagination.page - 1) * pagination.limit;

      // 사용자가 참여 중인 채팅방만 조회
      final participantChatRooms = await ChatParticipant.db.find(
        session,
        where: (participant) =>
            participant.userId.equals(userId) &
            participant.isActive.equals(true),
      );

      // 참여 중인 채팅방 ID 목록 추출
      final chatRoomIds = participantChatRooms
          .map((participant) => participant.chatRoomId)
          .toSet();

      if (chatRoomIds.isEmpty) {
        return _buildChatRoomsPaginationResponse([], 0, pagination);
      }

      // 전체 개수 조회
      final totalCount = await ChatRoom.db.count(
        session,
        where: (chatRoom) => chatRoom.id.inSet(chatRoomIds),
      );

      // 참여 중인 채팅방 조회 (페이지네이션 적용)
      final chatRooms = await ChatRoom.db.find(
        session,
        where: (chatRoom) => chatRoom.id.inSet(chatRoomIds),
        orderBy: (chatRoom) => chatRoom.lastActivityAt,
        orderDescending: true,
        limit: pagination.limit,
        offset: offset,
      );

      return _buildChatRoomsPaginationResponse(
          chatRooms, totalCount, pagination);
    } on Exception catch (e, stackTrace) {
      session.log(
        '❌ 내 채팅방 목록 조회 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 채팅방 참여
  Future<JoinChatRoomResponseDto> joinChatRoom(
    Session session,
    int userId,
    JoinChatRoomRequestDto request,
  ) async {
    try {
      // 1. 채팅방 존재 여부 확인
      var chatRoom = await ChatRoom.db.findById(
        session,
        request.chatRoomId,
      );
      if (chatRoom == null) {
        return JoinChatRoomResponseDto(
          success: false,
          chatRoomId: request.chatRoomId,
          joinedAt: DateTime.now().toUtc(),
          message: '채팅방을 찾을 수 없습니다.',
          participantCount: null,
        );
      }

      // 2. 이미 참여 중인지 확인
      final existingParticipant = await ChatParticipant.db.findFirstRow(
        session,
        where: (participant) =>
            participant.chatRoomId.equals(request.chatRoomId) &
            participant.userId.equals(userId) &
            participant.isActive.equals(true),
      );

      if (existingParticipant != null) {
        // 이미 참여 중인 경우
        session.log(
          '이미 참여 중인 사용자: '
          'chatRoomId=${request.chatRoomId}, '
          'userId=$userId',
          level: LogLevel.info,
        );

        return JoinChatRoomResponseDto(
          success: true,
          chatRoomId: request.chatRoomId,
          joinedAt: existingParticipant.joinedAt ?? DateTime.now().toUtc(),
          message: '이미 참여 중인 채팅방입니다.',
          participantCount: chatRoom.participantCount,
        );
      }

      // 3. 새로운 참여자 추가
      final now = DateTime.now().toUtc();
      await _addParticipant(
        session,
        request.chatRoomId,
        userId,
      );

      // 4. 참여자 수 업데이트
      await _updateParticipantCount(session, request.chatRoomId);

      // 5. 채팅방 최근 활동 시간 업데이트
      await ChatRoom.db.updateRow(
        session,
        chatRoom.copyWith(
          lastActivityAt: now,
          updatedAt: now,
        ),
      );

      // 6. 업데이트된 채팅방 정보 조회
      chatRoom = await ChatRoom.db.findById(
        session,
        request.chatRoomId,
      );

      session.log(
        '채팅방 참여 성공: '
        'chatRoomId=${request.chatRoomId}, '
        'userId=$userId',
        level: LogLevel.info,
      );

      return JoinChatRoomResponseDto(
        success: true,
        chatRoomId: request.chatRoomId,
        joinedAt: now,
        message: '채팅방에 성공적으로 참여했습니다.',
        participantCount: chatRoom?.participantCount,
      );
    } on Exception catch (e, stackTrace) {
      session.log(
        '채팅방 참여 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      return JoinChatRoomResponseDto(
        success: false,
        chatRoomId: request.chatRoomId,
        joinedAt: DateTime.now().toUtc(),
        message: '채팅방 참여 중 오류가 발생했습니다: $e',
        participantCount: null,
      );
    }
  }

  /// 채팅방 나가기
  Future<LeaveChatRoomResponseDto> leaveChatRoom(
    Session session,
    int userId,
    LeaveChatRoomRequestDto request,
  ) async {
    try {
      // 1. 채팅방 존재 여부 확인
      final chatRoom = await ChatRoom.db.findById(
        session,
        request.chatRoomId,
      );
      if (chatRoom == null) {
        return LeaveChatRoomResponseDto(
          success: false,
          chatRoomId: request.chatRoomId,
          message: '채팅방을 찾을 수 없습니다.',
        );
      }

      // 2. 참여자 찾기
      final participant = await ChatParticipant.db.findFirstRow(
        session,
        where: (p) =>
            p.chatRoomId.equals(request.chatRoomId) &
            p.userId.equals(userId) &
            p.isActive.equals(true),
      );

      if (participant == null) {
        return LeaveChatRoomResponseDto(
          success: false,
          chatRoomId: request.chatRoomId,
          message: '참여 중인 채팅방이 아닙니다.',
        );
      }

      // 3. 나가기 처리 (isActive = false)
      final now = DateTime.now().toUtc();
      await ChatParticipant.db.updateRow(
        session,
        participant.copyWith(
          isActive: false,
          leftAt: now,
          updatedAt: now,
        ),
      );

      // 4. 참여자 수 업데이트
      await _updateParticipantCount(session, request.chatRoomId);

      session.log(
        '채팅방 나가기 성공: '
        'chatRoomId=${request.chatRoomId}, '
        'userId=$userId',
        level: LogLevel.info,
      );

      return LeaveChatRoomResponseDto(
        success: true,
        chatRoomId: request.chatRoomId,
        message: '채팅방에서 나갔습니다.',
      );
    } on Exception catch (e, stackTrace) {
      session.log(
        '채팅방 나가기 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      return LeaveChatRoomResponseDto(
        success: false,
        chatRoomId: request.chatRoomId,
        message: '채팅방 나가기 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 채팅방 참여자 목록 조회
  Future<List<ChatParticipantInfoDto>> getChatParticipants(
    Session session,
    int chatRoomId,
  ) async {
    try {
      // 채팅방 존재 여부 확인
      final chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      if (chatRoom == null) {
        throw Exception('채팅방을 찾을 수 없습니다.');
      }

      // 활성 참여자 조회
      final participants = await ChatParticipant.db.find(
        session,
        where: (participant) =>
            participant.chatRoomId.equals(chatRoomId) &
            participant.isActive.equals(true),
      );

      // 참여자 정보 수집
      final participantInfos = <ChatParticipantInfoDto>[];

      for (final participant in participants) {
        // User 정보 조회
        final user = await User.db.findById(session, participant.userId);

        final participantInfo = ChatParticipantInfoDto(
          userId: participant.userId,
          nickname: user?.nickname,
          profileImageUrl: user?.profileImageUrl,
          joinedAt: participant.joinedAt,
          isActive: participant.isActive,
        );

        participantInfos.add(participantInfo);
      }

      return participantInfos;
    } on Exception catch (e, stackTrace) {
      session.log(
        '참여자 목록 조회 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 메시지 전송
  /// 카카오톡/당근마켓 방식: 첫 메시지 전송 시 채팅방 생성
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
        final createResult = await createOrGetChatRoom(
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
        await _addParticipant(
          session,
          chatRoomId,
          request.targetUserId!,
        );

        // 참여자 수 업데이트
        await _updateParticipantCount(session, chatRoomId);

        // 업데이트된 채팅방 정보 조회
        chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      } else {
        chatRoomId = request.chatRoomId!;

        // 채팅방 참여 확인
        final participation = await ChatParticipant.db.findFirstRow(
          session,
          where: (participant) =>
              participant.userId.equals(userId) &
              participant.chatRoomId.equals(chatRoomId) &
              participant.isActive.equals(true),
        );

        if (participation == null) {
          throw Exception('채팅방에 참여하지 않은 사용자입니다.');
        }

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

      // 6. Private 버킷 이미지인 경우 Presigned URL로 변환
      String? attachmentUrl = savedMessage.attachmentUrl;
      if (attachmentUrl != null &&
          savedMessage.messageType == MessageType.image) {
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
            '⚠️ Presigned URL 생성 실패: $e',
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
        content: savedMessage.content,
        messageType: savedMessage.messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: savedMessage.attachmentName,
        attachmentSize: savedMessage.attachmentSize,
        createdAt: savedMessage.createdAt ?? now,
        updatedAt: savedMessage.updatedAt,
      );

      // 8. 🚀 Redis 기반 글로벌 브로드캐스팅
      await session.messages.postMessage(
        'chat_room_$chatRoomId',
        response,
        global: true, // 🔥 Redis를 통한 글로벌 브로드캐스팅
      );

      session.log(
        '메시지 전송 완료: '
        'chatRoomId=$chatRoomId, '
        'senderId=$userId, '
        'messageId=${savedMessage.id}',
        level: LogLevel.info,
      );

      return response;
    } on Exception catch (e, stackTrace) {
      session.log(
        '메시지 전송 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 페이지네이션된 메시지 조회
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

      // 오프셋 계산
      final offset = (request.page - 1) * request.limit;

      // 전체 메시지 조회
      Expression<Object?> baseWhere(ChatMessageTable message) =>
          message.chatRoomId.equals(request.chatRoomId);

      final totalCount = await ChatMessage.db.count(session, where: baseWhere);

      // 메시지 조회 (최신 순으로 정렬)
      final messages = await ChatMessage.db.find(
        session,
        limit: request.limit,
        offset: offset,
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

      // 필터가 적용된 경우, 페이지네이션 기준 카운트도 필터 기준으로 계산
      var effectiveTotalCount = totalCount;
      if (request.messageType != null) {
        effectiveTotalCount = await ChatMessage.db.count(
          session,
          where: (message) =>
              message.chatRoomId.equals(request.chatRoomId) &
              message.messageType.equals(request.messageType),
        );
      }

      // ChatMessageResponseDto 리스트 생성
      final messageResponses = <ChatMessageResponseDto>[];
      for (final message in messages) {
        // 발신자 정보 조회
        final user = await User.db.findById(session, message.senderId);

        // Private 버킷 이미지인 경우 Presigned URL로 변환
        String? attachmentUrl = message.attachmentUrl;
        if (attachmentUrl != null &&
            message.messageType == MessageType.image) {
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
              '⚠️ Presigned URL 생성 실패: $e',
              level: LogLevel.warning,
            );
          }
        }

        final response = ChatMessageResponseDto(
          id: message.id!,
          chatRoomId: message.chatRoomId,
          senderId: message.senderId,
          senderNickname: user?.nickname,
          content: message.content,
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
        '메시지 조회 실패: $e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 채팅방의 마지막 메시지 조회
  Future<ChatMessage?> getLastMessageByChatRoomId(
    Session session,
    int chatRoomId,
  ) async {
    try {
      // 채팅방 존재 여부 확인
      final chatRoom = await ChatRoom.db.findById(session, chatRoomId);
      if (chatRoom == null) {
        session.log(
          '채팅방을 찾을 수 없음: chatRoomId=$chatRoomId',
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
          '채팅방에 메시지가 없음: chatRoomId=$chatRoomId',
          level: LogLevel.info,
        );
        return null;
      }

      return lastMessage;
    } on Exception catch (e, stackTrace) {
      session.log(
        '마지막 메시지 조회 실패: chatRoomId=$chatRoomId, error=$e',
        exception: e,
        level: LogLevel.error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // ==================== Private Helper Methods ====================

  /// 채팅방 페이지네이션 응답 생성
  PaginatedChatRoomsResponseDto _buildChatRoomsPaginationResponse(
    List<ChatRoom> chatRooms,
    int totalCount,
    PaginationDto pagination,
  ) {
    final offset = (pagination.page - 1) * pagination.limit;
    final hasMore = offset + chatRooms.length < totalCount;

    return PaginatedChatRoomsResponseDto(
      pagination: PaginationDto(
        page: pagination.page,
        limit: pagination.limit,
        totalCount: totalCount,
        hasMore: hasMore,
      ),
      chatRooms: chatRooms,
    );
  }

  /// 기존 1:1 채팅방 찾기
  Future<ChatRoom?> _findExistingDirectChatRoom(
    Session session,
    int productId,
    int userId1,
    int userId2,
  ) async {
    // userId1이 참여한 채팅방 찾기
    final participant1Rooms = await ChatParticipant.db.find(
      session,
      where: (p) => p.userId.equals(userId1) & p.isActive.equals(true),
    );

    final chatRoomIds1 = participant1Rooms.map((p) => p.chatRoomId).toSet();

    if (chatRoomIds1.isEmpty) {
      return null;
    }

    // 해당 상품의 채팅방만 필터링
    final productChatRooms = await ChatRoom.db.find(
      session,
      where: (room) =>
          room.productId.equals(productId) &
          room.id.inSet(chatRoomIds1) &
          room.chatRoomType.equals(ChatRoomType.direct),
    );

    // userId2도 참여한 채팅방 찾기
    for (final chatRoom in productChatRooms) {
      final participant2 = await ChatParticipant.db.findFirstRow(
        session,
        where: (p) =>
            p.chatRoomId.equals(chatRoom.id) &
            p.userId.equals(userId2) &
            p.isActive.equals(true),
      );

      if (participant2 != null) {
        return chatRoom;
      }
    }

    return null;
  }

  /// 참여자 추가
  Future<void> _addParticipant(
    Session session,
    int chatRoomId,
    int userId,
  ) async {
    // 이미 참여 중인지 확인
    final existing = await ChatParticipant.db.findFirstRow(
      session,
      where: (p) => p.chatRoomId.equals(chatRoomId) & p.userId.equals(userId),
    );

    if (existing != null) {
      // 이미 존재하면 활성화
      if (!existing.isActive) {
        final now = DateTime.now().toUtc();
        await ChatParticipant.db.updateRow(
          session,
          existing.copyWith(
            isActive: true,
            joinedAt: now,
            leftAt: null,
            updatedAt: now,
          ),
        );
      }
      return;
    }

    // 새 참여자 추가
    final now = DateTime.now().toUtc();
    final participant = ChatParticipant(
      chatRoomId: chatRoomId,
      userId: userId,
      joinedAt: now,
      isActive: true,
      leftAt: null,
      createdAt: now,
      updatedAt: now,
    );

    await ChatParticipant.db.insertRow(session, participant);
  }

  /// 참여자 수 업데이트
  Future<void> _updateParticipantCount(
    Session session,
    int chatRoomId,
  ) async {
    final chatRoom = await ChatRoom.db.findById(session, chatRoomId);
    if (chatRoom != null) {
      final count = await ChatParticipant.db.count(
        session,
        where: (participant) =>
            participant.chatRoomId.equals(chatRoomId) &
            participant.isActive.equals(true),
      );

      final updatedChatRoom = chatRoom.copyWith(
        participantCount: count,
        updatedAt: DateTime.now().toUtc(),
      );
      await ChatRoom.db.updateRow(session, updatedChatRoom);
    }
  }
}
