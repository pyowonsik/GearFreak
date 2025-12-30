import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';

/// 채팅 원격 데이터 소스
/// Data Layer: Serverpod Client를 사용한 API 호출
class ChatRemoteDataSource {
  /// ChatRemoteDataSource 생성자
  const ChatRemoteDataSource();

  /// Serverpod Client
  pod.Client get _client => PodService.instance.client;

  /// 🧪 Mock 데이터 사용 여부 (테스트용)
  static const bool _useMockData = false;

  // ==================== Public Methods (Repository에서 호출) ====================

  /// 채팅방 생성 또는 조회
  Future<pod.CreateChatRoomResponseDto> createOrGetChatRoom({
    required int productId,
    int? targetUserId,
  }) async {
    final request = pod.CreateChatRoomRequestDto(
      productId: productId,
      targetUserId: targetUserId,
    );
    return _client.chat.createOrGetChatRoom(request);
  }

  /// 채팅방 정보 조회
  Future<pod.ChatRoom?> getChatRoomById(int chatRoomId) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final now = DateTime.now();
      return pod.ChatRoom(
        id: chatRoomId,
        productId: chatRoomId % 10 + 1,
        chatRoomType: pod.ChatRoomType.direct,
        participantCount: 2,
        lastActivityAt: now.subtract(Duration(hours: chatRoomId)),
        createdAt: now.subtract(Duration(days: chatRoomId)),
        updatedAt: now.subtract(Duration(hours: chatRoomId)),
      );
    }

    return _client.chat.getChatRoomById(chatRoomId);
  }

  /// 사용자가 참여한 채팅방 목록 조회 (상품 ID 기준, 페이지네이션)
  Future<pod.PaginatedChatRoomsResponseDto> getUserChatRoomsByProductId({
    required int productId,
    required pod.PaginationDto pagination,
  }) async {
    if (_useMockData) {
      return _generateMockChatRooms(
        pagination: pagination,
        productId: productId,
      );
    }

    return _client.chat.getUserChatRoomsByProductId(productId, pagination);
  }

  /// 사용자가 참여한 모든 채팅방 목록 조회 (페이지네이션)
  Future<pod.PaginatedChatRoomsResponseDto> getMyChatRooms({
    required pod.PaginationDto pagination,
  }) async {
    if (_useMockData) {
      return _generateMockChatRooms(pagination: pagination);
    }

    return _client.chat.getMyChatRooms(pagination);
  }

  // ==================== Private Helper Methods ====================

  /// 🧪 Mock 채팅방 목록 생성
  Future<pod.PaginatedChatRoomsResponseDto> _generateMockChatRooms({
    required pod.PaginationDto pagination,
    int? productId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // 60개의 다양한 날짜 범위를 가진 채팅방 생성 (테스트용)
    // 시간 단위(1~23시간), 일 단위(1~6일), 주 단위(1~3주),
    // 개월 단위(1~12개월), 년 단위(1년 이상) 포함
    final allChatRooms = List.generate(60, (index) {
      final now = DateTime.now();
      Duration lastActivityAgo;

      if (index < 23) {
        // 0-22: 1시간 전 ~ 23시간 전 (시간 단위 테스트 - 오늘 표시)
        lastActivityAgo = Duration(hours: index + 1);
      } else if (index < 29) {
        // 23-28: 1일 전 ~ 6일 전 (일 단위 테스트)
        lastActivityAgo = Duration(days: index - 22);
      } else if (index < 32) {
        // 29-31: 1주일 전, 2주일 전, 3주일 전 (주 단위 테스트)
        lastActivityAgo = Duration(days: (index - 28) * 7);
      } else if (index < 44) {
        // 32-43: 1개월 전 ~ 12개월 전 (개월 단위 테스트)
        final months = index - 31;
        lastActivityAgo = Duration(days: months * 30); // 대략 30일 기준
      } else {
        // 44-59: 1년 전 ~ 16년 전 (년 단위 테스트, 1년, 2년 등 포함)
        final years = index - 43;
        lastActivityAgo = Duration(days: years * 365);
      }

      final lastActivityAt = now.subtract(lastActivityAgo);
      // createdAt은 lastActivityAt보다 약간 더 오래되도록 설정
      final createdAtAgo = lastActivityAgo + Duration(days: index % 7);
      final createdAt = now.subtract(createdAtAgo);

      return pod.ChatRoom(
        id: index + 1,
        productId: productId ?? ((index % 10) + 1),
        chatRoomType: pod.ChatRoomType.direct,
        participantCount: 2,
        lastActivityAt: lastActivityAt,
        createdAt: createdAt,
        updatedAt: lastActivityAt,
      );
    });

    // 페이지네이션 적용
    final offset = (pagination.page - 1) * pagination.limit;
    final endIndex = (offset + pagination.limit).clamp(
      0,
      allChatRooms.length,
    );
    final paginatedChatRooms = allChatRooms.sublist(
      offset.clamp(0, allChatRooms.length),
      endIndex,
    );

    final totalCount = allChatRooms.length;
    final hasMore = endIndex < totalCount;

    return pod.PaginatedChatRoomsResponseDto(
      pagination: pod.PaginationDto(
        page: pagination.page,
        limit: pagination.limit,
        totalCount: totalCount,
        hasMore: hasMore,
      ),
      chatRooms: paginatedChatRooms,
    );
  }

  /// 🧪 Mock 채팅 메시지 생성
  Future<pod.PaginatedChatMessagesResponseDto> _generateMockMessages({
    required int chatRoomId,
    required int page,
    required int limit,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    const totalMockMessages = 500;
    final now = DateTime.now();
    final messages = <pod.ChatMessageResponseDto>[];

    for (var i = 0; i < totalMockMessages; i++) {
      final messageId = totalMockMessages - i; // 최신 메시지가 먼저
      final isMine = i.isEven;

      // 다양한 날짜 범위로 메시지 생성 (테스트용)
      // 시간 단위, 일 단위, 주 단위, 개월 단위, 년 단위 포함
      Duration timeAgo;
      if (i < 48) {
        // 0-47: 오늘의 메시지들 (30분 간격, 24시간 범위)
        timeAgo = Duration(minutes: i * 30);
      } else if (i < 72) {
        // 48-71: 1일 전 ~ 3일 전 (하루에 여러 메시지)
        final daysAgo = (i - 48) ~/ 8 + 1; // 1일, 2일, 3일
        final hoursInDay = (i - 48) % 8; // 하루 내 시간 (0~7시간)
        timeAgo = Duration(days: daysAgo, hours: hoursInDay);
      } else if (i < 100) {
        // 72-99: 1주일 전 ~ 4주일 전
        final weeksAgo = (i - 72) ~/ 7 + 1; // 1주, 2주, 3주, 4주
        final daysInWeek = (i - 72) % 7; // 주 내 날짜 (0~6일)
        timeAgo = Duration(days: weeksAgo * 7 + daysInWeek);
      } else if (i < 200) {
        // 100-199: 1개월 전 ~ 12개월 전
        final monthsAgo = (i - 100) ~/ 10 + 1; // 1개월 ~ 10개월
        final daysInMonth = (i - 100) % 10; // 월 내 날짜
        timeAgo = Duration(days: monthsAgo * 30 + daysInMonth);
      } else {
        // 200-499: 1년 전 ~ 5년 전
        final yearsAgo = (i - 200) ~/ 60 + 1; // 1년 ~ 5년
        final daysInYear = (i - 200) % 60; // 년 내 날짜
        timeAgo = Duration(days: yearsAgo * 365 + daysInYear);
      }

      messages.add(
        pod.ChatMessageResponseDto(
          id: messageId,
          chatRoomId: chatRoomId,
          senderId: isMine ? 2 : 1,
          content: '메시지 내용 $messageId',
          messageType: pod.MessageType.text,
          createdAt: now.subtract(timeAgo),
          updatedAt: now.subtract(timeAgo),
        ),
      );
    }

    // 페이지네이션 처리 (최신 메시지부터)
    final offset = (page - 1) * limit;
    final endIndex = (offset + limit).clamp(0, messages.length);
    final paginatedMessages = messages.sublist(
      offset.clamp(0, messages.length),
      endIndex,
    );

    final totalPages = (totalMockMessages / limit).ceil();
    final hasMore = page < totalPages;

    return pod.PaginatedChatMessagesResponseDto(
      messages: paginatedMessages,
      pagination: pod.PaginationDto(
        page: page,
        limit: limit,
        totalCount: totalMockMessages,
        hasMore: hasMore,
      ),
    );
  }

  /// 채팅방 참여
  Future<pod.JoinChatRoomResponseDto> joinChatRoom(int chatRoomId) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return pod.JoinChatRoomResponseDto(
        success: true,
        chatRoomId: chatRoomId,
        joinedAt: DateTime.now().toUtc(),
        message: '채팅방에 참여했습니다.',
        participantCount: 2,
      );
    }

    final request = pod.JoinChatRoomRequestDto(chatRoomId: chatRoomId);
    return _client.chat.joinChatRoom(request);
  }

  /// 채팅방 나가기
  Future<pod.LeaveChatRoomResponseDto> leaveChatRoom(int chatRoomId) async {
    final request = pod.LeaveChatRoomRequestDto(chatRoomId: chatRoomId);
    return _client.chat.leaveChatRoom(request);
  }

  /// 채팅방 참여자 목록 조회
  Future<List<pod.ChatParticipantInfoDto>> getChatParticipants(
    int chatRoomId,
  ) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return [
        pod.ChatParticipantInfoDto(
          userId: 1,
          nickname: '사용자1',
          profileImageUrl: 'https://picsum.photos/seed/1/200',
          joinedAt: DateTime.now().subtract(const Duration(days: 1)),
          isActive: true,
          isNotificationEnabled: true,
        ),
        pod.ChatParticipantInfoDto(
          userId: 2,
          nickname: '장비충#abc123',
          profileImageUrl: 'https://picsum.photos/seed/2/200',
          joinedAt: DateTime.now().subtract(const Duration(days: 1)),
          isActive: true,
          isNotificationEnabled: true,
        ),
      ];
    }

    return _client.chat.getChatParticipants(chatRoomId);
  }

  /// 채팅 메시지 조회 (페이지네이션)
  Future<pod.PaginatedChatMessagesResponseDto> getChatMessages({
    required int chatRoomId,
    int page = 1,
    int limit = 50,
    pod.MessageType? messageType,
  }) async {
    if (_useMockData) {
      return _generateMockMessages(
        chatRoomId: chatRoomId,
        page: page,
        limit: limit,
      );
    }

    final request = pod.GetChatMessagesRequestDto(
      chatRoomId: chatRoomId,
      page: page,
      limit: limit,
      messageType: messageType,
    );
    return _client.chat.getChatMessagesPaginated(request);
  }

  /// 메시지 전송
  Future<pod.ChatMessageResponseDto> sendMessage({
    required String content,
    required pod.MessageType messageType,
    int? chatRoomId,
    int? productId,
    int? targetUserId,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) async {
    final request = pod.SendMessageRequestDto(
      chatRoomId: chatRoomId,
      productId: productId,
      targetUserId: targetUserId,
      content: content,
      messageType: messageType,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      attachmentSize: attachmentSize,
    );
    return _client.chat.sendMessage(request);
  }

  /// 채팅방 읽음 처리
  /// 채팅방의 모든 메시지를 읽음 처리합니다.
  Future<void> markChatRoomAsRead(int chatRoomId) async {
    await _client.chat.markChatRoomAsRead(chatRoomId);
  }

  /// 채팅방 알림 설정 변경
  Future<void> updateChatRoomNotification({
    required int chatRoomId,
    required bool isNotificationEnabled,
  }) async {
    final request = pod.UpdateChatRoomNotificationRequestDto(
      chatRoomId: chatRoomId,
      isNotificationEnabled: isNotificationEnabled,
    );
    await _client.chat.updateChatRoomNotification(request);
  }

  /// 채팅 메시지 스트림 구독 (실시간 메시지 수신)
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  /// 반환: 실시간 메시지 스트림
  Stream<pod.ChatMessageResponseDto> subscribeChatMessageStream(
    int chatRoomId,
  ) {
    return _client.chatStream.chatMessageStream(chatRoomId);
  }

  /// 전체 채팅방의 읽지 않은 메시지 총합 조회
  /// 사용자가 참여 중인 모든 채팅방에서 읽지 않은 메시지 개수의 합을 반환합니다.
  Future<int> getTotalUnreadChatCount() async {
    return _client.chat.getTotalUnreadChatCount();
  }
}
