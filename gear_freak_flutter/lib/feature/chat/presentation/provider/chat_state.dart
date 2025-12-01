import 'package:gear_freak_flutter/feature/chat/domain/entity/chat_message.dart';

/// Chat 상태
class ChatState {
  /// ChatState 생성자
  ///
  /// [chatList]는 채팅 목록입니다.
  /// [isLoading]는 로딩 상태입니다.
  /// [error]는 에러 메시지입니다.
  const ChatState({
    this.chatList = const [],
    this.isLoading = false,
    this.error,
  });

  /// Chat 상태 생성자
  final List<ChatMessage> chatList;

  /// Chat 상태 로딩 여부
  final bool isLoading;

  /// Chat 상태 에러 메시지
  final String? error;

  /// ChatState 복사
  ChatState copyWith({
    List<ChatMessage>? chatList,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      chatList: chatList ?? this.chatList,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}


