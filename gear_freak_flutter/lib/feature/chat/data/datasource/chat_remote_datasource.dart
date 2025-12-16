import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';

/// 채팅 원격 데이터 소스
/// Data Layer: Serverpod Client를 사용한 API 호출
class ChatRemoteDataSource {
  /// ChatRemoteDataSource 생성자
  const ChatRemoteDataSource();

  /// Serverpod Client
  pod.Client get _client => PodService.instance.client;

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
    return _client.chat.getChatRoomById(chatRoomId);
  }

  /// 사용자가 참여한 채팅방 목록 조회 (상품 ID 기준, 페이지네이션)
  Future<pod.PaginatedChatRoomsResponseDto> getUserChatRoomsByProductId({
    required int productId,
    required pod.PaginationDto pagination,
  }) async {
    return _client.chat.getUserChatRoomsByProductId(productId, pagination);
    // return _getHardcodedChatRooms(pagination);
  }

  /// 사용자가 참여한 모든 채팅방 목록 조회 (페이지네이션)
  Future<pod.PaginatedChatRoomsResponseDto> getMyChatRooms({
    required pod.PaginationDto pagination,
  }) async {
    return _client.chat.getMyChatRooms(pagination);
    // return _getHardcodedChatRooms(pagination);
  }

  // // ==================== Private Helper Methods ====================

  // /// 테스트용 하드코딩된 채팅방 목록 반환
  // Future<pod.PaginatedChatRoomsResponseDto> _getHardcodedChatRooms(
  //   pod.PaginationDto pagination,
  // ) async {
  //   // 60개의 하드코딩된 채팅방 생성
  //   final allChatRooms = List.generate(60, (index) {
  //     final now = DateTime.now();
  //     final lastActivityAt = now.subtract(Duration(hours: index));
  //     return pod.ChatRoom(
  //       id: index + 1,
  //       productId: (index % 10) + 1,
  //       title: '채팅방 ${index + 1}',
  //       chatRoomType: pod.ChatRoomType.direct,
  //       participantCount: 2,
  //       lastActivityAt: lastActivityAt,
  //       createdAt: now.subtract(Duration(days: index)),
  //       updatedAt: lastActivityAt,
  //     );
  //   });

  //   // 페이지네이션 적용
  //   final offset = (pagination.page - 1) * pagination.limit;
  //   final endIndex = (offset + pagination.limit).clamp(
  //     0,
  //     allChatRooms.length,
  //   );
  //   final paginatedChatRooms = allChatRooms.sublist(
  //     offset.clamp(0, allChatRooms.length),
  //     endIndex,
  //   );

  //   final totalCount = allChatRooms.length;
  //   final hasMore = endIndex < totalCount;

  //   return pod.PaginatedChatRoomsResponseDto(
  //     pagination: pod.PaginationDto(
  //       page: pagination.page,
  //       limit: pagination.limit,
  //       totalCount: totalCount,
  //       hasMore: hasMore,
  //     ),
  //     chatRooms: paginatedChatRooms,
  //   );
  // }

  /// 채팅방 참여
  Future<pod.JoinChatRoomResponseDto> joinChatRoom(int chatRoomId) async {
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
    return _client.chat.getChatParticipants(chatRoomId);
  }

  /// 채팅 메시지 조회 (페이지네이션)
  Future<pod.PaginatedChatMessagesResponseDto> getChatMessages({
    required int chatRoomId,
    int page = 1,
    int limit = 50,
    pod.MessageType? messageType,
  }) async {
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
}
