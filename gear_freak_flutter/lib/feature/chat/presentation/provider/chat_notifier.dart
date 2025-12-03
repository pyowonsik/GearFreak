import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_list_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';

/// Chat Notifier
/// Presentation Layer: Riverpod 상태 관리
class ChatNotifier extends StateNotifier<ChatState> {
  /// ChatNotifier 생성자
  ///
  /// [getChatListUseCase]는 채팅 목록 조회 UseCase 인스턴스입니다.
  ChatNotifier(this.getChatListUseCase) : super(const ChatState());

  /// 채팅 목록 조회 UseCase 인스턴스
  final GetChatListUseCase getChatListUseCase;

  // ==================== Public Methods (UseCase 호출) ====================

  /// 채팅 목록 조회
  Future<void> loadChatList() async {
    state = state.copyWith(isLoading: true);

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

  // ==================== Public Methods (Service 호출) ====================

  // ==================== Private Helper Methods ====================
}
