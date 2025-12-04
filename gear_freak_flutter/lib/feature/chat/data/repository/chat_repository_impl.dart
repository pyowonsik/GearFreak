import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/data/datasource/chat_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/chat/domain/entity/chat_message.dart';
import 'package:gear_freak_flutter/feature/chat/domain/repository/chat_repository.dart';

/// 채팅 Repository 구현
/// Data Layer: Repository 인터페이스 구현
class ChatRepositoryImpl implements ChatRepository {
  /// ChatRepositoryImpl 생성자
  ///
  /// [remoteDataSource]는 채팅 원격 데이터 소스입니다.
  const ChatRepositoryImpl(this.remoteDataSource);

  /// 채팅 원격 데이터 소스
  final ChatRemoteDataSource remoteDataSource;

  // ==================== Public Methods (UseCase에서 호출) ====================

  @override
  Future<pod.CreateChatRoomResponseDto> createOrGetChatRoom({
    required int productId,
    int? targetUserId,
  }) async {
    return remoteDataSource.createOrGetChatRoom(
      productId: productId,
      targetUserId: targetUserId,
    );
  }

  @override
  Future<pod.ChatRoom?> getChatRoomById(int chatRoomId) async {
    return remoteDataSource.getChatRoomById(chatRoomId);
  }

  @override
  Future<List<pod.ChatRoom>?> getUserChatRoomsByProductId(int productId) async {
    return remoteDataSource.getUserChatRoomsByProductId(productId);
  }

  @override
  Future<List<pod.ChatRoom>?> getMyChatRooms() async {
    return remoteDataSource.getMyChatRooms();
  }

  @override
  Future<pod.JoinChatRoomResponseDto> joinChatRoom(int chatRoomId) async {
    return remoteDataSource.joinChatRoom(chatRoomId);
  }

  @override
  Future<List<pod.ChatParticipantInfoDto>> getChatParticipants(
    int chatRoomId,
  ) async {
    return remoteDataSource.getChatParticipants(chatRoomId);
  }

  @override
  Future<pod.PaginatedChatMessagesResponseDto> getChatMessages({
    required int chatRoomId,
    int page = 1,
    int limit = 50,
    pod.MessageType? messageType,
  }) async {
    return remoteDataSource.getChatMessages(
      chatRoomId: chatRoomId,
      page: page,
      limit: limit,
      messageType: messageType,
    );
  }

  @override
  Future<pod.ChatMessageResponseDto> sendMessage({
    required int chatRoomId,
    required String content,
    required pod.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) async {
    return remoteDataSource.sendMessage(
      chatRoomId: chatRoomId,
      content: content,
      messageType: messageType,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      attachmentSize: attachmentSize,
    );
  }

  @override
  Future<void> markAsRead(String messageId) async {}

  @override
  Stream<pod.ChatMessageResponseDto> subscribeChatMessageStream(
    int chatRoomId,
  ) {
    return remoteDataSource.subscribeChatMessageStream(chatRoomId);
  }

  // ==================== Private Helper Methods ====================

  /// JSON을 Entity로 변환
  ChatMessage _toEntity(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
