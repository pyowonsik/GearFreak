import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 채팅 Repository 인터페이스
/// Domain Layer: 데이터 소스 추상화
abstract class ChatRepository {
  /// 채팅방 생성 또는 조회
  Future<pod.CreateChatRoomResponseDto> createOrGetChatRoom({
    required int productId,
    int? targetUserId,
  });

  /// 채팅방 정보 조회
  Future<pod.ChatRoom?> getChatRoomById(int chatRoomId);

  /// 사용자가 참여한 채팅방 목록 조회 (상품 ID 기준, 페이지네이션)
  Future<pod.PaginatedChatRoomsResponseDto> getUserChatRoomsByProductId({
    required int productId,
    required pod.PaginationDto pagination,
  });

  /// 사용자가 참여한 모든 채팅방 목록 조회 (페이지네이션)
  Future<pod.PaginatedChatRoomsResponseDto> getMyChatRooms({
    required pod.PaginationDto pagination,
  });

  /// 채팅방 참여
  Future<pod.JoinChatRoomResponseDto> joinChatRoom(int chatRoomId);

  /// 채팅방 참여자 목록 조회
  Future<List<pod.ChatParticipantInfoDto>> getChatParticipants(int chatRoomId);

  /// 특정 채팅방의 메시지 조회 (페이지네이션)
  Future<pod.PaginatedChatMessagesResponseDto> getChatMessages({
    required int chatRoomId,
    int page = 1,
    int limit = 50,
    pod.MessageType? messageType,
  });

  /// 메시지 전송
  Future<pod.ChatMessageResponseDto> sendMessage({
    int? chatRoomId,
    int? productId,
    int? targetUserId,
    required String content,
    required pod.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  });

  /// 메시지 읽음 처리
  Future<void> markAsRead(String messageId);

  /// 채팅 메시지 스트림 구독 (실시간 메시지 수신)
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  /// 반환: 실시간 메시지 스트림
  Stream<pod.ChatMessageResponseDto> subscribeChatMessageStream(int chatRoomId);
}
