/// 채팅 메시지 엔티티
/// Domain Layer: 순수 Dart 클래스, 비즈니스 로직 포함
class ChatMessage {
  /// 채팅 메시지 생성자
  ///
  /// [id]는 채팅 메시지 ID입니다.
  /// [senderId]는 채팅 메시지 발신자 ID입니다.
  /// [senderName]는 채팅 메시지 발신자 이름입니다.
  /// [content]는 채팅 메시지 내용입니다.
  /// [timestamp]는 채팅 메시지 발신 시간입니다.
  /// [isRead]는 채팅 메시지 읽음 여부입니다.
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  /// 채팅 메시지 ID
  final String id;

  /// 채팅 메시지 발신자 ID
  final String senderId;

  /// 채팅 메시지 발신자 이름
  final String senderName;

  /// 채팅 메시지 내용
  final String content;

  /// 채팅 메시지 발신 시간
  final DateTime timestamp;

  /// 채팅 메시지 읽음 여부
  final bool isRead;

  /// 읽지 않은 메시지인지 확인
  bool get isUnread => !isRead;

  /// 메시지 복사
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
