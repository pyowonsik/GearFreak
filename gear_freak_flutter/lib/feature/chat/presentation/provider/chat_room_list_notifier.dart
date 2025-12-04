import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_my_chat_rooms_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_room_list_state.dart';

/// 채팅방 목록 Notifier
/// Presentation Layer: Riverpod 상태 관리
class ChatRoomListNotifier extends StateNotifier<ChatRoomListState> {
  /// ChatRoomListNotifier 생성자
  ///
  /// [getMyChatRoomsUseCase]는 내 채팅방 목록 조회 UseCase입니다.
  ChatRoomListNotifier(
    this.getMyChatRoomsUseCase,
  ) : super(const ChatRoomListInitial());

  final GetMyChatRoomsUseCase getMyChatRoomsUseCase;

  // ==================== Public Methods (UseCase 호출) ====================

  /// 채팅방 목록 로드
  Future<void> loadChatRooms() async {
    state = const ChatRoomListLoading();

    final result = await getMyChatRoomsUseCase(
      const GetMyChatRoomsParams(),
    );

    result.fold(
      (failure) {
        state = ChatRoomListError(failure.message);
      },
      (chatRooms) {
        state = ChatRoomListLoaded(
          chatRooms: chatRooms ?? [],
        );
      },
    );
  }

  // ==================== Public Methods (Service 호출) ====================

  // ==================== Private Helper Methods ====================
}
