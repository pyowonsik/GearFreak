import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_participants_usecase.dart';
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
  /// [getChatParticipantsUseCase]는 채팅방 참여자 목록 조회 UseCase입니다.
  ChatRoomListNotifier(
    this.getMyChatRoomsUseCase,
    this.getUserChatRoomsByProductIdUseCase,
    this.getChatParticipantsUseCase,
  ) : super(const ChatRoomListInitial());

  /// 내 채팅방 목록 조회 UseCase
  final GetMyChatRoomsUseCase getMyChatRoomsUseCase;

  /// 특정 상품의 채팅방 목록 조회 UseCase
  final GetUserChatRoomsByProductIdUseCase getUserChatRoomsByProductIdUseCase;

  /// 채팅방 참여자 목록 조회 UseCase
  final GetChatParticipantsUseCase getChatParticipantsUseCase;

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

    await result.fold(
      (failure) {
        state = ChatRoomListError(failure.message);
      },
      (response) async {
        // 참여자 정보 조회
        final participantsMap = await _loadParticipants(response.chatRooms);
        state = ChatRoomListLoaded(
          chatRooms: response.chatRooms,
          pagination: response.pagination,
          participantsMap: participantsMap,
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
      participantsMap: currentState.participantsMap,
    );

    final nextPagination = pod.PaginationDto(
      page: pagination.page + 1,
      limit: pagination.limit,
    );

    final result = await getMyChatRoomsUseCase(
      GetMyChatRoomsParams(pagination: nextPagination),
    );

    await result.fold(
      (failure) {
        // 에러 발생 시 이전 상태로 복구
        state = currentState;
      },
      (response) async {
        // 새로 로드된 채팅방들의 참여자 정보 조회
        final newParticipantsMap = await _loadParticipants(response.chatRooms);
        // 기존 참여자 정보와 병합
        final mergedParticipantsMap = {
          ...currentState.participantsMap,
          ...newParticipantsMap,
        };
        state = ChatRoomListLoaded(
          chatRooms: [...currentState.chatRooms, ...response.chatRooms],
          pagination: response.pagination,
          participantsMap: mergedParticipantsMap,
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

    await result.fold(
      (failure) {
        state = ChatRoomListError(failure.message);
      },
      (response) async {
        // 참여자 정보 조회
        final participantsMap = await _loadParticipants(response.chatRooms);
        state = ChatRoomListLoaded(
          chatRooms: response.chatRooms,
          pagination: response.pagination,
          participantsMap: participantsMap,
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

    await result.fold(
      (failure) {
        // 에러 발생 시 이전 상태로 복구
        state = currentState;
      },
      (response) async {
        // 새로 로드된 채팅방들의 참여자 정보 조회
        final newParticipantsMap = await _loadParticipants(response.chatRooms);
        // 기존 참여자 정보와 병합
        final mergedParticipantsMap = {
          ...currentState.participantsMap,
          ...newParticipantsMap,
        };
        state = ChatRoomListLoaded(
          chatRooms: [...currentState.chatRooms, ...response.chatRooms],
          pagination: response.pagination,
          participantsMap: mergedParticipantsMap,
        );
      },
    );
  }

  // ==================== Public Methods (Service 호출) ====================

  // ==================== Private Helper Methods ====================

  /// 채팅방 목록의 참여자 정보 조회 (병렬 처리)
  Future<Map<int, List<pod.ChatParticipantInfoDto>>> _loadParticipants(
    List<pod.ChatRoom> chatRooms,
  ) async {
    final participantsMap = <int, List<pod.ChatParticipantInfoDto>>{};

    // 모든 채팅방의 참여자 정보를 병렬로 조회
    final futures = chatRooms.map((chatRoom) async {
      if (chatRoom.id == null) {
        return null;
      }

      final result = await getChatParticipantsUseCase(
        GetChatParticipantsParams(chatRoomId: chatRoom.id!),
      );

      return result.fold(
        (failure) => null,
        (participants) => (chatRoom.id!, participants),
      );
    });

    final results = await Future.wait(futures);

    for (final result in results) {
      if (result != null) {
        participantsMap[result.$1] = result.$2;
      }
    }
    return participantsMap;
  }
}
