import '../entity/chat_message.dart';

/// 채팅 Repository 인터페이스
/// Domain Layer: 데이터 소스 추상화
abstract class ChatRepository {
  /// 채팅 목록 조회
  Future<List<ChatMessage>> getChatList();

  /// 특정 채팅방의 메시지 조회
  Future<List<ChatMessage>> getChatMessages(String chatRoomId);

  /// 메시지 전송
  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String content,
  });

  /// 메시지 읽음 처리
  Future<void> markAsRead(String messageId);
}

