import 'package:gear_freak_server/src/feature/chat/service/chat_notification_service.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 채팅방 서비스
/// 채팅방 생성, 조회, 참여/나가기 관련 비즈니스 로직을 처리합니다.
class ChatRoomService {
  final ChatNotificationService _notificationService =
      ChatNotificationService();

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
          isNewChatRoom: false,
        );
      }

      // 2. 사용자 ID 확인
      if (userId <= 0) {
        return CreateChatRoomResponseDto(
          success: false,
          chatRoomId: null,
          chatRoom: null,
          message: '유효하지 않은 사용자 ID입니다.',
          isNewChatRoom: false,
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
            isNewChatRoom: false,
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
          isNewChatRoom: false,
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
          isNewChatRoom: false,
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

      // 6-1. 상품의 chatCount 증가
      final currentChatCount = product.chatCount ?? 0;
      await Product.db.updateRow(
        session,
        product.copyWith(chatCount: currentChatCount + 1),
        columns: (t) => [t.chatCount],
      );

      // 7. 참여자 추가 (현재 사용자만 추가, 상대방은 메시지 전송 시 추가)
      final chatRoomId = createdChatRoom.id;
      if (chatRoomId == null) {
        return CreateChatRoomResponseDto(
          success: false,
          chatRoomId: null,
          chatRoom: null,
          message: '채팅방 생성에 실패했습니다.',
          isNewChatRoom: false,
        );
      }

      await addParticipant(
        session,
        chatRoomId,
        userId,
      );

      // 8. 참여자 수 업데이트
      await updateParticipantCount(session, chatRoomId);

      // 10. 업데이트된 채팅방 정보 조회 (unreadCount 포함)
      final updatedChatRoom = await getChatRoomById(
        session,
        createdChatRoom.id!,
        userId: userId,
      );

      return CreateChatRoomResponseDto(
        success: true,
        chatRoomId: updatedChatRoom?.id,
        chatRoom: updatedChatRoom,
        message: '채팅방이 성공적으로 생성되었습니다.',
        isNewChatRoom: true,
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
        isNewChatRoom: false,
      );
    }
  }

  /// 채팅방 정보 조회
  /// [userId]가 제공되면 해당 사용자의 unreadCount를 계산하여 반환
  Future<ChatRoom?> getChatRoomById(
    Session session,
    int chatRoomId, {
    int? userId,
  }) async {
    try {
      final chatRoom = await ChatRoom.db.findById(session, chatRoomId);

      if (chatRoom == null) {
        return null;
      }

      // userId가 제공되면 unreadCount 계산
      if (userId != null) {
        final unreadCount = await _notificationService.getUnreadCount(
          session,
          userId,
          chatRoomId,
        );
        return chatRoom.copyWith(unreadCount: unreadCount);
      }

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

      // 각 채팅방별로 안 읽은 메시지 개수 계산
      final chatRoomsWithUnreadCount = await Future.wait(
        chatRooms.map((chatRoom) async {
          final unreadCount = await _notificationService.getUnreadCount(
            session,
            userId,
            chatRoom.id!,
          );
          return chatRoom.copyWith(unreadCount: unreadCount);
        }),
      );

      return _buildChatRoomsPaginationResponse(
          chatRoomsWithUnreadCount, totalCount, pagination);
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

      // 각 채팅방별로 안 읽은 메시지 개수 계산
      final chatRoomsWithUnreadCount = await Future.wait(
        chatRooms.map((chatRoom) async {
          final unreadCount = await _notificationService.getUnreadCount(
            session,
            userId,
            chatRoom.id!,
          );
          return chatRoom.copyWith(unreadCount: unreadCount);
        }),
      );

      return _buildChatRoomsPaginationResponse(
          chatRoomsWithUnreadCount, totalCount, pagination);
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

      // 2. 참여자 확인 (isActive 여부와 관계없이 조회)
      final existingParticipant = await ChatParticipant.db.findFirstRow(
        session,
        where: (participant) =>
            participant.chatRoomId.equals(request.chatRoomId) &
            participant.userId.equals(userId),
      );

      final now = DateTime.now().toUtc();

      if (existingParticipant != null) {
        // 참여자가 이미 존재하는 경우
        if (existingParticipant.isActive) {
          // 이미 활성 상태인 경우
          session.log(
            '이미 참여 중인 사용자: '
            'chatRoomId=${request.chatRoomId}, '
            'userId=$userId',
            level: LogLevel.info,
          );

          return JoinChatRoomResponseDto(
            success: true,
            chatRoomId: request.chatRoomId,
            joinedAt: existingParticipant.joinedAt ?? now,
            message: '이미 참여 중인 채팅방입니다.',
            participantCount: chatRoom.participantCount,
          );
        } else {
          // 비활성 상태인 경우 재활성화
          final previousLeftAt = existingParticipant.leftAt; // 이전 leftAt 값 유지
          await ChatParticipant.db.updateRow(
            session,
            existingParticipant.copyWith(
              isActive: true,
              joinedAt: now,
              leftAt: previousLeftAt, // leftAt 유지 (재참여 후 필터링 기준)
              updatedAt: now,
            ),
          );
          session.log(
            '채팅방 재참여 (joinChatRoom): chatRoomId=${request.chatRoomId}, userId=$userId, previousLeftAt=$previousLeftAt',
            level: LogLevel.info,
          );
        }
      } else {
        // 3. 새로운 참여자 추가
        await addParticipant(
          session,
          request.chatRoomId,
          userId,
        );
      }

      // 4. 참여자 수 업데이트
      await updateParticipantCount(session, request.chatRoomId);

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
      await updateParticipantCount(session, request.chatRoomId);

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
          isNotificationEnabled: participant.isNotificationEnabled,
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

  /// 참여자 추가 (public - ChatMessageService에서 사용)
  Future<void> addParticipant(
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
      // 이미 존재하면 활성화 (알림 설정은 유지)
      if (!existing.isActive) {
        final now = DateTime.now().toUtc();
        await ChatParticipant.db.updateRow(
          session,
          existing.copyWith(
            isActive: true,
            joinedAt: now,
            leftAt: null,
            updatedAt: now,
            // isNotificationEnabled는 기존 값 유지 (명시하지 않으면 기존 값 유지)
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
      isNotificationEnabled: true, // 기본값: 알림 활성화
      createdAt: now,
      updatedAt: now,
    );

    await ChatParticipant.db.insertRow(session, participant);
  }

  /// 참여자 수 업데이트 (public - ChatMessageService에서 사용)
  Future<void> updateParticipantCount(
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
