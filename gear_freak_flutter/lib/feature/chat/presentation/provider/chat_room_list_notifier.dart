import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_my_chat_rooms_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_user_chat_rooms_by_product_id_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_room_list_state.dart';

/// 채팅방 목록 Notifier
/// Presentation Layer: Riverpod 상태 관리
class ChatRoomListNotifier extends StateNotifier<ChatRoomListState> {
  /// ChatRoomListNotifier 생성자
  ///
  /// [getMyChatRoomsUseCase]는 내 채팅방 목록 조회 UseCase입니다.
  /// [getUserChatRoomsByProductIdUseCase]는 특정 상품의 채팅방 목록 조회 UseCase입니다.
  ChatRoomListNotifier(
    this.getMyChatRoomsUseCase,
    this.getUserChatRoomsByProductIdUseCase,
  ) : super(const ChatRoomListInitial());

  final GetMyChatRoomsUseCase getMyChatRoomsUseCase;
  final GetUserChatRoomsByProductIdUseCase getUserChatRoomsByProductIdUseCase;

  // ==================== Public Methods (UseCase 호출) ====================

  /// 채팅방 목록 로드 (모든 채팅방, 첫 페이지)
  Future<void> loadChatRooms({
    int page = 1,
    int limit = 20,
  }) async {
    state = const ChatRoomListLoading();

    final pagination = pod.PaginationDto(
      page: page,
      limit: limit,
    );

    final result = await getMyChatRoomsUseCase(
      GetMyChatRoomsParams(pagination: pagination),
    );

    result.fold(
      (failure) {
        state = ChatRoomListError(failure.message);
      },
      (response) {
        state = ChatRoomListLoaded(
          chatRooms: response.chatRooms,
          pagination: response.pagination,
        );
      },
    );
  }

  /// 채팅방 목록 더 불러오기 (다음 페이지)
  Future<void> loadMoreChatRooms() async {
    final currentState = state;
    if (currentState is! ChatRoomListLoaded) {
      return;
    }

    final pagination = currentState.pagination;
    if (!(pagination.hasMore ?? false)) {
      return;
    }

    state = ChatRoomListLoadingMore(
      chatRooms: currentState.chatRooms,
      pagination: pagination,
    );

    final nextPagination = pod.PaginationDto(
      page: pagination.page + 1,
      limit: pagination.limit,
    );

    final result = await getMyChatRoomsUseCase(
      GetMyChatRoomsParams(pagination: nextPagination),
    );

    result.fold(
      (failure) {
        // 에러 발생 시 이전 상태로 복구
        state = currentState;
      },
      (response) {
        state = ChatRoomListLoaded(
          chatRooms: [...currentState.chatRooms, ...response.chatRooms],
          pagination: response.pagination,
        );
      },
    );
  }

  /// 특정 상품의 채팅방 목록 로드 (첫 페이지)
  Future<void> loadChatRoomsByProductId(
    int productId, {
    int page = 1,
    int limit = 20,
  }) async {
    state = const ChatRoomListLoading();

    final pagination = pod.PaginationDto(
      page: page,
      limit: limit,
    );

    final result = await getUserChatRoomsByProductIdUseCase(
      GetUserChatRoomsByProductIdParams(
        productId: productId,
        pagination: pagination,
      ),
    );

    result.fold(
      (failure) {
        state = ChatRoomListError(failure.message);
      },
      (response) {
        state = ChatRoomListLoaded(
          chatRooms: response.chatRooms,
          pagination: response.pagination,
        );
      },
    );
  }

  /// 특정 상품의 채팅방 목록 더 불러오기 (다음 페이지)
  Future<void> loadMoreChatRoomsByProductId(int productId) async {
    final currentState = state;
    if (currentState is! ChatRoomListLoaded) {
      return;
    }

    final pagination = currentState.pagination;
    if (!(pagination.hasMore ?? false)) {
      return;
    }

    state = ChatRoomListLoadingMore(
      chatRooms: currentState.chatRooms,
      pagination: pagination,
    );

    final nextPagination = pod.PaginationDto(
      page: pagination.page + 1,
      limit: pagination.limit,
    );

    final result = await getUserChatRoomsByProductIdUseCase(
      GetUserChatRoomsByProductIdParams(
        productId: productId,
        pagination: nextPagination,
      ),
    );

    result.fold(
      (failure) {
        // 에러 발생 시 이전 상태로 복구
        state = currentState;
      },
      (response) {
        state = ChatRoomListLoaded(
          chatRooms: [...currentState.chatRooms, ...response.chatRooms],
          pagination: response.pagination,
        );
      },
    );
  }

  // ==================== Public Methods (Service 호출) ====================

  // ==================== Private Helper Methods ====================
}
