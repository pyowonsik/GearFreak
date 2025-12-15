import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_messages_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_participants_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_my_chat_rooms_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_user_chat_rooms_by_product_id_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_room_list_state.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';

/// 채팅방 목록 Notifier
/// Presentation Layer: Riverpod 상태 관리
class ChatRoomListNotifier extends StateNotifier<ChatRoomListState> {
  /// ChatRoomListNotifier 생성자
  ///
  /// [getMyChatRoomsUseCase]는 내 채팅방 목록 조회 UseCase입니다.
  /// [getUserChatRoomsByProductIdUseCase]는 특정 상품의 채팅방 목록 조회 UseCase입니다.
  /// [getChatParticipantsUseCase]는 채팅방 참여자 목록 조회 UseCase입니다.
  /// [getChatMessagesUseCase]는 채팅 메시지 조회 UseCase입니다.
  /// [getProductDetailUseCase]는 상품 상세 조회 UseCase입니다.
  ChatRoomListNotifier(
    this.ref,
    this.getMyChatRoomsUseCase,
    this.getUserChatRoomsByProductIdUseCase,
    this.getChatParticipantsUseCase,
    this.getChatMessagesUseCase,
    this.getProductDetailUseCase,
  ) : super(const ChatRoomListInitial()) {
    // 채팅방 읽음 처리 이벤트 감지하여 자동으로 unreadCount 업데이트
    ref
      ..listen<int?>(chatRoomReadProvider, (previous, next) {
        if (next != null) {
          _updateChatRoomUnreadCount(next, 0);
        }
      })

      // 새 메시지 이벤트 감지하여 자동으로 마지막 메시지와 시간 업데이트
      ..listen<pod.ChatMessageResponseDto?>(
        newChatMessageProvider,
        (previous, next) {
          if (next != null) {
            _updateLastMessage(next);
          }
        },
      );
  }

  /// Riverpod Ref 인스턴스
  final Ref ref;

  /// 내 채팅방 목록 조회 UseCase
  final GetMyChatRoomsUseCase getMyChatRoomsUseCase;

  /// 특정 상품의 채팅방 목록 조회 UseCase
  final GetUserChatRoomsByProductIdUseCase getUserChatRoomsByProductIdUseCase;

  /// 채팅방 참여자 목록 조회 UseCase
  final GetChatParticipantsUseCase getChatParticipantsUseCase;

  /// 채팅 메시지 조회 UseCase
  final GetChatMessagesUseCase getChatMessagesUseCase;

  /// 상품 상세 조회 UseCase
  final GetProductDetailUseCase getProductDetailUseCase;

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
        // 마지막 메시지 조회
        final lastMessagesMap = await _loadLastMessages(response.chatRooms);
        // 상품 이미지 조회
        final productImagesMap = await _loadProductImages(response.chatRooms);
        state = ChatRoomListLoaded(
          chatRooms: response.chatRooms,
          pagination: response.pagination,
          participantsMap: participantsMap,
          lastMessagesMap: lastMessagesMap,
          productImagesMap: productImagesMap,
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
      lastMessagesMap: currentState.lastMessagesMap,
      productImagesMap: currentState.productImagesMap,
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
        // 새로 로드된 채팅방들의 마지막 메시지 조회
        final newLastMessagesMap = await _loadLastMessages(response.chatRooms);
        // 기존 마지막 메시지 정보와 병합
        final mergedLastMessagesMap = {
          ...currentState.lastMessagesMap,
          ...newLastMessagesMap,
        };
        // 새로 로드된 채팅방들의 상품 이미지 조회
        final newProductImagesMap =
            await _loadProductImages(response.chatRooms);
        // 기존 상품 이미지 정보와 병합
        final mergedProductImagesMap = {
          ...currentState.productImagesMap,
          ...newProductImagesMap,
        };
        state = currentState.copyWith(
          chatRooms: [...currentState.chatRooms, ...response.chatRooms],
          pagination: response.pagination,
          participantsMap: mergedParticipantsMap,
          lastMessagesMap: mergedLastMessagesMap,
          productImagesMap: mergedProductImagesMap,
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
        // 마지막 메시지 조회
        final lastMessagesMap = await _loadLastMessages(response.chatRooms);
        // 상품 이미지 조회
        final productImagesMap = await _loadProductImages(response.chatRooms);
        state = ChatRoomListLoaded(
          chatRooms: response.chatRooms,
          pagination: response.pagination,
          participantsMap: participantsMap,
          lastMessagesMap: lastMessagesMap,
          productImagesMap: productImagesMap,
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
      participantsMap: currentState.participantsMap,
      lastMessagesMap: currentState.lastMessagesMap,
      productImagesMap: currentState.productImagesMap,
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
        // 새로 로드된 채팅방들의 마지막 메시지 조회
        final newLastMessagesMap = await _loadLastMessages(response.chatRooms);
        // 기존 마지막 메시지 정보와 병합
        final mergedLastMessagesMap = {
          ...currentState.lastMessagesMap,
          ...newLastMessagesMap,
        };
        // 새로 로드된 채팅방들의 상품 이미지 조회
        final newProductImagesMap =
            await _loadProductImages(response.chatRooms);
        // 기존 상품 이미지 정보와 병합
        final mergedProductImagesMap = {
          ...currentState.productImagesMap,
          ...newProductImagesMap,
        };
        state = currentState.copyWith(
          chatRooms: [...currentState.chatRooms, ...response.chatRooms],
          pagination: response.pagination,
          participantsMap: mergedParticipantsMap,
          lastMessagesMap: mergedLastMessagesMap,
          productImagesMap: mergedProductImagesMap,
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

  /// 채팅방 목록의 마지막 메시지 조회 (병렬 처리)
  Future<Map<int, pod.ChatMessageResponseDto>> _loadLastMessages(
    List<pod.ChatRoom> chatRooms,
  ) async {
    final lastMessagesMap = <int, pod.ChatMessageResponseDto>{};

    // 모든 채팅방의 마지막 메시지를 병렬로 조회
    final futures = chatRooms.map((chatRoom) async {
      if (chatRoom.id == null) {
        return null;
      }

      final result = await getChatMessagesUseCase(
        GetChatMessagesParams(
          chatRoomId: chatRoom.id!,
          limit: 1, // 마지막 메시지만 가져오기
        ),
      );

      return result.fold(
        (failure) => null,
        (pagination) {
          // 메시지가 있으면 첫 번째 메시지(가장 최근) 반환
          if (pagination.messages.isNotEmpty) {
            return (chatRoom.id!, pagination.messages.first);
          }
          return null;
        },
      );
    });

    final results = await Future.wait(futures);

    for (final result in results) {
      if (result != null) {
        lastMessagesMap[result.$1] = result.$2;
      }
    }
    return lastMessagesMap;
  }

  /// 채팅방 목록의 상품 이미지 조회 (병렬 처리)
  Future<Map<int, String>> _loadProductImages(
    List<pod.ChatRoom> chatRooms,
  ) async {
    final productImagesMap = <int, String>{};

    // 중복 제거된 productId 목록
    final productIds = chatRooms.map((room) => room.productId).toSet();

    // 모든 상품의 이미지를 병렬로 조회
    final futures = productIds.map((productId) async {
      final result = await getProductDetailUseCase(productId);

      return result.fold(
        (failure) => null,
        (product) {
          // 첫 번째 이미지 URL 반환
          if (product.imageUrls != null && product.imageUrls!.isNotEmpty) {
            return (productId, product.imageUrls!.first);
          }
          return null;
        },
      );
    });

    final results = await Future.wait(futures);

    for (final result in results) {
      if (result != null) {
        productImagesMap[result.$1] = result.$2;
      }
    }
    return productImagesMap;
  }

  /// 채팅방의 안 읽은 메시지 개수 업데이트 (읽음 처리 이벤트에 의해 자동 호출)
  void _updateChatRoomUnreadCount(int chatRoomId, int unreadCount) {
    final currentState = state;

    if (currentState is ChatRoomListLoaded) {
      _updateUnreadCountInLoaded(chatRoomId, unreadCount, currentState);
    } else if (currentState is ChatRoomListLoadingMore) {
      _updateUnreadCountInLoadingMore(chatRoomId, unreadCount, currentState);
    }
  }

  /// ChatRoomListLoaded 상태에서 안 읽은 메시지 개수 업데이트
  void _updateUnreadCountInLoaded(
    int chatRoomId,
    int unreadCount,
    ChatRoomListLoaded currentState,
  ) {
    final updatedChatRooms = _updateChatRoomInList(
      currentState.chatRooms,
      chatRoomId,
      (chatRoom) => chatRoom.copyWith(unreadCount: unreadCount),
    );

    if (_hasChatRoom(currentState.chatRooms, chatRoomId)) {
      debugPrint(
        '✅ [ChatRoomListNotifier] 안 읽은 메시지 개수 업데이트: chatRoomId=$chatRoomId, unreadCount=$unreadCount',
      );

      state = currentState.copyWith(chatRooms: updatedChatRooms);
    }
  }

  /// ChatRoomListLoadingMore 상태에서 안 읽은 메시지 개수 업데이트
  void _updateUnreadCountInLoadingMore(
    int chatRoomId,
    int unreadCount,
    ChatRoomListLoadingMore currentState,
  ) {
    final updatedChatRooms = _updateChatRoomInList(
      currentState.chatRooms,
      chatRoomId,
      (chatRoom) => chatRoom.copyWith(unreadCount: unreadCount),
    );

    if (_hasChatRoom(currentState.chatRooms, chatRoomId)) {
      debugPrint(
        '✅ [ChatRoomListNotifier] 안 읽은 메시지 개수 업데이트: chatRoomId=$chatRoomId, unreadCount=$unreadCount',
      );

      state = currentState.copyWith(chatRooms: updatedChatRooms);
    }
  }

  /// 마지막 메시지 업데이트 (새 메시지 이벤트에 의해 자동 호출)
  void _updateLastMessage(pod.ChatMessageResponseDto message) {
    final currentState = state;

    if (currentState is ChatRoomListLoaded) {
      _updateLastMessageInLoaded(message, currentState);
    } else if (currentState is ChatRoomListLoadingMore) {
      _updateLastMessageInLoadingMore(message, currentState);
    }
  }

  /// 채팅방 목록에서 특정 채팅방을 업데이트
  List<pod.ChatRoom> _updateChatRoomInList(
    List<pod.ChatRoom> chatRooms,
    int chatRoomId,
    pod.ChatRoom Function(pod.ChatRoom) updateFn,
  ) {
    return chatRooms.map((chatRoom) {
      if (chatRoom.id == chatRoomId) {
        return updateFn(chatRoom);
      }
      return chatRoom;
    }).toList();
  }

  /// 채팅방 목록에 특정 채팅방이 존재하는지 확인
  bool _hasChatRoom(List<pod.ChatRoom> chatRooms, int chatRoomId) {
    return chatRooms.any((room) => room.id == chatRoomId);
  }

  /// 채팅방 목록을 lastActivityAt 기준으로 내림차순 정렬 (최신이 위)
  /// null인 경우 맨 아래로 정렬
  void _sortChatRoomsByLastActivity(List<pod.ChatRoom> chatRooms) {
    chatRooms.sort((a, b) {
      final aTime = a.lastActivityAt;
      final bTime = b.lastActivityAt;

      // null인 경우 맨 아래로
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      // 내림차순 정렬 (최신이 위)
      return bTime.compareTo(aTime);
    });
  }

  /// ChatRoomListLoaded 상태에서 마지막 메시지 업데이트
  void _updateLastMessageInLoaded(
    pod.ChatMessageResponseDto message,
    ChatRoomListLoaded currentState,
  ) {
    final chatRoomId = message.chatRoomId;

    // 마지막 메시지 맵 업데이트
    final updatedLastMessagesMap = {
      ...currentState.lastMessagesMap,
      chatRoomId: message,
    };

    // 채팅방의 lastActivityAt 업데이트
    final updatedChatRooms = _updateChatRoomInList(
      currentState.chatRooms,
      chatRoomId,
      (chatRoom) => chatRoom.copyWith(
        lastActivityAt: message.createdAt,
      ),
    );

    // 정렬 (공통 메서드 호출)
    _sortChatRoomsByLastActivity(updatedChatRooms);

    if (_hasChatRoom(currentState.chatRooms, chatRoomId)) {
      debugPrint(
        '📩 [ChatRoomListNotifier] 마지막 메시지 업데이트 및 정렬: chatRoomId=$chatRoomId',
      );

      state = currentState.copyWith(
        chatRooms: updatedChatRooms,
        lastMessagesMap: updatedLastMessagesMap,
      );
    }
  }

  /// ChatRoomListLoadingMore 상태에서 마지막 메시지 업데이트
  void _updateLastMessageInLoadingMore(
    pod.ChatMessageResponseDto message,
    ChatRoomListLoadingMore currentState,
  ) {
    final chatRoomId = message.chatRoomId;

    // 마지막 메시지 맵 업데이트
    final updatedLastMessagesMap = {
      ...currentState.lastMessagesMap,
      chatRoomId: message,
    };

    // 채팅방의 lastActivityAt 업데이트
    final updatedChatRooms = _updateChatRoomInList(
      currentState.chatRooms,
      chatRoomId,
      (chatRoom) => chatRoom.copyWith(
        lastActivityAt: message.createdAt,
      ),
    );

    // 정렬 (공통 메서드 호출)
    _sortChatRoomsByLastActivity(updatedChatRooms);

    if (_hasChatRoom(currentState.chatRooms, chatRoomId)) {
      debugPrint(
        '📩 [ChatRoomListNotifier] 마지막 메시지 업데이트 및 정렬: chatRoomId=$chatRoomId',
      );

      state = currentState.copyWith(
        chatRooms: updatedChatRooms,
        lastMessagesMap: updatedLastMessagesMap,
      );
    }
  }
}
