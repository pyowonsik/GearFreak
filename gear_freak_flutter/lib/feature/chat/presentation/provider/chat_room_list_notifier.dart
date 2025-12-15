import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_messages_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_participants_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_room_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_my_chat_rooms_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_user_chat_rooms_by_product_id_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/leave_chat_room_usecase.dart';
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
  /// [getChatRoomByIdUseCase]는 채팅방 정보 조회 UseCase입니다.
  /// [leaveChatRoomUseCase]는 채팅방 나가기 UseCase입니다.
  ChatRoomListNotifier(
    this.ref,
    this.getMyChatRoomsUseCase,
    this.getUserChatRoomsByProductIdUseCase,
    this.getChatParticipantsUseCase,
    this.getChatMessagesUseCase,
    this.getProductDetailUseCase,
    this.getChatRoomByIdUseCase,
    this.leaveChatRoomUseCase,
  ) : super(const ChatRoomListInitial()) {
    // 채팅방 읽음 처리 이벤트 감지하여 자동으로 unreadCount 업데이트 및 최신 정보 갱신
    ref
      // 채팅방 읽음 처리 시 최신 채팅방 정보 갱신
      // 서버의 getUnreadCount가 정확한 값을 반환하므로, 클라이언트에서 임의로 0으로 설정하지 않음
      ..listen<int?>(chatRoomReadProvider, (previous, next) {
        if (next != null) {
          _refreshChatRoomInfo(next);
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

  /// 채팅방 정보 조회 UseCase
  final GetChatRoomByIdUseCase getChatRoomByIdUseCase;

  /// 채팅방 나가기 UseCase
  final LeaveChatRoomUseCase leaveChatRoomUseCase;

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

  /// 채팅방 정보 갱신 (FCM 알림 수신 시 또는 뒤로가기 시 최신 정보로 업데이트)
  /// 외부에서 호출 가능한 public 메서드
  Future<void> refreshChatRoomInfo(int chatRoomId) async {
    await _refreshChatRoomInfo(chatRoomId);
  }

  /// 채팅방 나가기
  /// 외부에서 호출 가능한 public 메서드
  Future<bool> leaveChatRoom(int chatRoomId) async {
    try {
      debugPrint(
          '🚪 [ChatRoomListNotifier] 채팅방 나가기 시도: chatRoomId=$chatRoomId');

      final result = await leaveChatRoomUseCase(
        LeaveChatRoomParams(chatRoomId: chatRoomId),
      );

      return result.fold(
        (failure) {
          debugPrint(
            '❌ [ChatRoomListNotifier] 채팅방 나가기 실패: '
            'chatRoomId=$chatRoomId, error=${failure.message}',
          );
          return false;
        },
        (response) {
          debugPrint(
            '✅ [ChatRoomListNotifier] 채팅방 나가기 성공: '
            'chatRoomId=$chatRoomId, message=${response.message}',
          );

          // UI에서 채팅방 제거
          _removeChatRoomFromList(chatRoomId);
          return true;
        },
      );
    } catch (e) {
      debugPrint(
        '❌ [ChatRoomListNotifier] 채팅방 나가기 실패: '
        'chatRoomId=$chatRoomId, error=$e',
      );
      return false;
    }
  }

  /// 채팅방 정보 갱신 (내부 구현)
  Future<void> _refreshChatRoomInfo(int chatRoomId) async {
    final currentState = state;
    if (currentState is! ChatRoomListLoaded &&
        currentState is! ChatRoomListLoadingMore) {
      return;
    }

    try {
      // 1. 채팅방 정보 조회
      final roomResult = await getChatRoomByIdUseCase(
        GetChatRoomByIdParams(chatRoomId: chatRoomId),
      );

      await roomResult.fold(
        (failure) {
          debugPrint(
            '⚠️ [ChatRoomListNotifier] 채팅방 정보 조회 실패: chatRoomId=$chatRoomId,'
            ' error=${failure.message}',
          );
        },
        (chatRoom) async {
          if (chatRoom == null) {
            debugPrint(
              '⚠️ [ChatRoomListNotifier] 채팅방을 찾을 수 없음: chatRoomId=$chatRoomId',
            );
            return;
          }

          // 2. 마지막 메시지 조회
          final messagesResult = await getChatMessagesUseCase(
            GetChatMessagesParams(
              chatRoomId: chatRoomId,
              limit: 1,
            ),
          );

          await messagesResult.fold(
            (failure) {
              debugPrint(
                '⚠️ [ChatRoomListNotifier] 마지막 메시지 조회 실패: '
                'chatRoomId=$chatRoomId, error=${failure.message}',
              );
            },
            (messagesData) async {
              final lastMessage = messagesData.messages.isNotEmpty
                  ? messagesData.messages.first
                  : null;

              // 3. 새 메시지 이벤트 발행 (FCM 알림으로 받은 경우)
              // 이렇게 하면 채팅방 리스트가 자동으로 업데이트됨
              // _updateLastMessage가 리스너에서 호출되어 마지막 메시지와 시간이 업데이트됨
              if (lastMessage != null) {
                ref.read(newChatMessageProvider.notifier).state = lastMessage;
                // 이벤트 처리 후 초기화 (다음 메시지를 위해)
                await Future.microtask(() {
                  ref.read(newChatMessageProvider.notifier).state = null;
                });
              }

              // 4. 채팅방 정보 업데이트 (unreadCount 등)
              // 채팅방 정보가 변경되었을 수 있으므로 업데이트
              if (currentState is ChatRoomListLoaded) {
                _updateChatRoomWithLatestInfoLoaded(
                  chatRoom,
                  lastMessage,
                  currentState,
                );
              } else if (currentState is ChatRoomListLoadingMore) {
                _updateChatRoomWithLatestInfoLoadingMore(
                  chatRoom,
                  lastMessage,
                  currentState,
                );
              }
            },
          );
        },
      );
    } catch (e) {
      debugPrint(
        '❌ [ChatRoomListNotifier] 채팅방 정보 갱신 실패: '
        ' chatRoomId=$chatRoomId, error=$e',
      );
    }
  }

  /// 채팅방 정보를 최신 정보로 업데이트 (Loaded 상태)
  void _updateChatRoomWithLatestInfoLoaded(
    pod.ChatRoom chatRoom,
    pod.ChatMessageResponseDto? lastMessage,
    ChatRoomListLoaded currentState,
  ) {
    final chatRoomId = chatRoom.id!;

    // 채팅방 리스트에 해당 채팅방이 있는지 확인
    final existingChatRoomIndex =
        currentState.chatRooms.indexWhere((r) => r.id == chatRoomId);

    List<pod.ChatRoom> updatedChatRooms;
    Map<int, pod.ChatMessageResponseDto> updatedLastMessagesMap;

    if (existingChatRoomIndex >= 0) {
      // 기존 채팅방 업데이트
      updatedChatRooms = List.from(currentState.chatRooms);
      updatedChatRooms[existingChatRoomIndex] = chatRoom;
      updatedLastMessagesMap = {
        ...currentState.lastMessagesMap,
      };
      if (lastMessage != null) {
        updatedLastMessagesMap[chatRoomId] = lastMessage;
      }
    } else {
      // 새 채팅방 추가 (리스트 맨 위에 추가)
      updatedChatRooms = [chatRoom, ...currentState.chatRooms];
      updatedLastMessagesMap = {
        ...currentState.lastMessagesMap,
      };
      if (lastMessage != null) {
        updatedLastMessagesMap[chatRoomId] = lastMessage;
      }
    }

    // 정렬
    _sortChatRoomsByLastActivity(updatedChatRooms);

    debugPrint(
      '✅ [ChatRoomListNotifier] 채팅방 정보 갱신 완료: chatRoomId=$chatRoomId',
    );

    state = currentState.copyWith(
      chatRooms: updatedChatRooms,
      lastMessagesMap: updatedLastMessagesMap,
    );
  }

  /// 채팅방 정보를 최신 정보로 업데이트 (LoadingMore 상태)
  void _updateChatRoomWithLatestInfoLoadingMore(
    pod.ChatRoom chatRoom,
    pod.ChatMessageResponseDto? lastMessage,
    ChatRoomListLoadingMore currentState,
  ) {
    final chatRoomId = chatRoom.id!;

    // 채팅방 리스트에 해당 채팅방이 있는지 확인
    final existingChatRoomIndex =
        currentState.chatRooms.indexWhere((r) => r.id == chatRoomId);

    List<pod.ChatRoom> updatedChatRooms;
    Map<int, pod.ChatMessageResponseDto> updatedLastMessagesMap;

    if (existingChatRoomIndex >= 0) {
      // 기존 채팅방 업데이트
      updatedChatRooms = List.from(currentState.chatRooms);
      updatedChatRooms[existingChatRoomIndex] = chatRoom;
      updatedLastMessagesMap = {
        ...currentState.lastMessagesMap,
      };
      if (lastMessage != null) {
        updatedLastMessagesMap[chatRoomId] = lastMessage;
      }
    } else {
      // 새 채팅방 추가 (리스트 맨 위에 추가)
      updatedChatRooms = [chatRoom, ...currentState.chatRooms];
      updatedLastMessagesMap = {
        ...currentState.lastMessagesMap,
      };
      if (lastMessage != null) {
        updatedLastMessagesMap[chatRoomId] = lastMessage;
      }
    }

    // 정렬
    _sortChatRoomsByLastActivity(updatedChatRooms);

    debugPrint(
      '✅ [ChatRoomListNotifier] 채팅방 정보 갱신 완료: chatRoomId=$chatRoomId',
    );

    state = currentState.copyWith(
      chatRooms: updatedChatRooms,
      lastMessagesMap: updatedLastMessagesMap,
    );
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

  /// 채팅방 목록에서 특정 채팅방 제거 (나가기 후)
  void _removeChatRoomFromList(int chatRoomId) {
    final currentState = state;
    if (currentState is! ChatRoomListLoaded &&
        currentState is! ChatRoomListLoadingMore) {
      return;
    }

    if (currentState is ChatRoomListLoaded) {
      final updatedChatRooms =
          currentState.chatRooms.where((r) => r.id != chatRoomId).toList();
      final updatedParticipantsMap =
          Map<int, List<pod.ChatParticipantInfoDto>>.from(
        currentState.participantsMap,
      )..remove(chatRoomId);
      final updatedLastMessagesMap = Map<int, pod.ChatMessageResponseDto>.from(
        currentState.lastMessagesMap,
      )..remove(chatRoomId);
      final updatedProductImagesMap = Map<int, String>.from(
        currentState.productImagesMap,
      )..remove(chatRoomId);

      state = currentState.copyWith(
        chatRooms: updatedChatRooms,
        participantsMap: updatedParticipantsMap,
        lastMessagesMap: updatedLastMessagesMap,
        productImagesMap: updatedProductImagesMap,
      );

      debugPrint(
          '🗑️ [ChatRoomListNotifier] 채팅방 목록에서 제거: chatRoomId=$chatRoomId');
    } else if (currentState is ChatRoomListLoadingMore) {
      final updatedChatRooms =
          currentState.chatRooms.where((r) => r.id != chatRoomId).toList();
      final updatedParticipantsMap =
          Map<int, List<pod.ChatParticipantInfoDto>>.from(
        currentState.participantsMap,
      )..remove(chatRoomId);
      final updatedLastMessagesMap = Map<int, pod.ChatMessageResponseDto>.from(
        currentState.lastMessagesMap,
      )..remove(chatRoomId);
      final updatedProductImagesMap = Map<int, String>.from(
        currentState.productImagesMap,
      )..remove(chatRoomId);

      state = currentState.copyWith(
        chatRooms: updatedChatRooms,
        participantsMap: updatedParticipantsMap,
        lastMessagesMap: updatedLastMessagesMap,
        productImagesMap: updatedProductImagesMap,
      );

      debugPrint(
          '🗑️ [ChatRoomListNotifier] 채팅방 목록에서 제거: chatRoomId=$chatRoomId');
    }
  }
}
