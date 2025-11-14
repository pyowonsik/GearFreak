import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/chat_message.dart';
import '../../domain/usecase/get_chat_list_usecase.dart';

/// Chat 상태
class ChatState {
  final List<ChatMessage> chatList;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.chatList = const [],
    this.isLoading = false,
    this.error,
  });

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

/// Chat Notifier
/// Presentation Layer: Riverpod 상태 관리
class ChatNotifier extends StateNotifier<ChatState> {
  final GetChatListUseCase getChatListUseCase;

  ChatNotifier(this.getChatListUseCase) : super(const ChatState());

  /// 채팅 목록 조회
  Future<void> loadChatList() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getChatListUseCase(null);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (chatList) {
        state = state.copyWith(
          chatList: chatList,
          isLoading: false,
        );
      },
    );
  }
}
