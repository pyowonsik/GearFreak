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

  @override
  Future<List<ChatMessage>> getChatList() async {
    final data = await remoteDataSource.getChatList();
    return data.map(_toEntity).toList();
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String chatRoomId) async {
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
  Future<void> markAsRead(String messageId) async {}

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
