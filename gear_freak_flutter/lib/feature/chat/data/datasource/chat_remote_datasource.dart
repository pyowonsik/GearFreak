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

  /// 사용자가 참여한 채팅방 목록 조회 (상품 ID 기준)
  Future<List<pod.ChatRoom>?> getUserChatRoomsByProductId(int productId) async {
    return _client.chat.getUserChatRoomsByProductId(productId);
  }

  /// 사용자가 참여한 모든 채팅방 목록 조회
  Future<List<pod.ChatRoom>?> getMyChatRooms() async {
    return _client.chat.getMyChatRooms();
  }

  /// 채팅방 참여
  Future<pod.JoinChatRoomResponseDto> joinChatRoom(int chatRoomId) async {
    final request = pod.JoinChatRoomRequestDto(chatRoomId: chatRoomId);
    return _client.chat.joinChatRoom(request);
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
    required int chatRoomId,
    required String content,
    required pod.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) async {
    final request = pod.SendMessageRequestDto(
      chatRoomId: chatRoomId,
      content: content,
      messageType: messageType,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      attachmentSize: attachmentSize,
    );
    return _client.chat.sendMessage(request);
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
