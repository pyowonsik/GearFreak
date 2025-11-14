import '../../domain/entity/chat_message.dart';
import '../../domain/repository/chat_repository.dart';
import '../datasource/chat_remote_datasource.dart';

/// 채팅 Repository 구현
/// Data Layer: Repository 인터페이스 구현
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ChatMessage>> getChatList() async {
    final data = await remoteDataSource.getChatList();
    return data.map((json) => _toEntity(json)).toList();
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String chatRoomId) async {
    // TODO: 구현
    return [];
  }

  @override
  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String content,
  }) async {
    final data = await remoteDataSource.sendMessage(
      chatRoomId: chatRoomId,
      content: content,
    );
    return _toEntity(data);
  }

  @override
  Future<void> markAsRead(String messageId) async {
    // TODO: 구현
  }

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

