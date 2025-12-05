import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/usecase/create_or_get_chat_room_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_messages_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_participants_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_room_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/join_chat_room_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/send_message_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/subscribe_chat_message_stream_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';

/// 채팅 Notifier
/// Presentation Layer: Riverpod 상태 관리
class ChatNotifier extends StateNotifier<ChatState> {
  /// ChatNotifier 생성자
  ///
  /// [createOrGetChatRoomUseCase]는 채팅방 생성/조회 UseCase입니다.
  /// [getChatRoomByIdUseCase]는 채팅방 정보 조회 UseCase입니다.
  /// [joinChatRoomUseCase]는 채팅방 참여 UseCase입니다.
  /// [getChatParticipantsUseCase]는 참여자 목록 조회 UseCase입니다.
  /// [getChatMessagesUseCase]는 메시지 조회 UseCase입니다.
  /// [sendMessageUseCase]는 메시지 전송 UseCase입니다.
  /// [subscribeChatMessageStreamUseCase]는 메시지 스트림 구독 UseCase입니다.
  ChatNotifier(
    this.createOrGetChatRoomUseCase,
    this.getChatRoomByIdUseCase,
    this.joinChatRoomUseCase,
    this.getChatParticipantsUseCase,
    this.getChatMessagesUseCase,
    this.sendMessageUseCase,
    this.subscribeChatMessageStreamUseCase,
  ) : super(const ChatInitial()) {
    _messageStreamSubscription = null;
  }

  /// 채팅방 생성/조회 UseCase
  final CreateOrGetChatRoomUseCase createOrGetChatRoomUseCase;

  /// 채팅방 정보 조회 UseCase
  final GetChatRoomByIdUseCase getChatRoomByIdUseCase;

  /// 채팅방 참여 UseCase
  final JoinChatRoomUseCase joinChatRoomUseCase;

  /// 참여자 목록 조회 UseCase
  final GetChatParticipantsUseCase getChatParticipantsUseCase;

  /// 메시지 조회 UseCase
  final GetChatMessagesUseCase getChatMessagesUseCase;

  /// 메시지 전송 UseCase
  final SendMessageUseCase sendMessageUseCase;

  /// 메시지 스트림 구독 UseCase
  final SubscribeChatMessageStreamUseCase subscribeChatMessageStreamUseCase;

  /// 메시지 스트림 구독
  StreamSubscription<pod.ChatMessageResponseDto>? _messageStreamSubscription;

  // ==================== Public Methods (UseCase 호출) ====================

  /// 채팅방 생성 또는 조회 및 진입
  /// 상품 상세 화면에서 "1:1 채팅하기" 버튼 클릭 시 호출
  Future<void> createOrGetChatRoomAndEnter({
    required int productId,
    int? targetUserId,
  }) async {
    state = const ChatLoading();

    // 1. 채팅방 생성 또는 조회
    final createResult = await createOrGetChatRoomUseCase(
      CreateOrGetChatRoomParams(
        productId: productId,
        targetUserId: targetUserId,
      ),
    );

    await createResult.fold(
      (failure) async {
        state = ChatError(failure.message);
      },
      (response) async {
        if (!response.success || response.chatRoomId == null) {
          state = ChatError(response.message ?? '채팅방 생성에 실패했습니다.');
          return;
        }

        final chatRoomId = response.chatRoomId!;

        // 2. 채팅방 정보 조회
        final roomResult = await getChatRoomByIdUseCase(
          GetChatRoomByIdParams(chatRoomId: chatRoomId),
        );

        await roomResult.fold(
          (failure) async {
            state = ChatError(failure.message);
          },
          (chatRoom) async {
            if (chatRoom == null) {
              state = const ChatError('채팅방 정보를 찾을 수 없습니다.');
              return;
            }

            // 3. 채팅방 참여
            final joinResult = await joinChatRoomUseCase(
              JoinChatRoomParams(chatRoomId: chatRoomId),
            );

            await joinResult.fold(
              (failure) async {
                state = ChatError(failure.message);
              },
              (joinResponse) async {
                if (!joinResponse.success) {
                  state = ChatError(joinResponse.message ?? '채팅방 참여에 실패했습니다.');
                  return;
                }

                // 4. 참여자 목록 조회
                final participantsResult = await getChatParticipantsUseCase(
                  GetChatParticipantsParams(chatRoomId: chatRoomId),
                );

                final participants = participantsResult.fold(
                  (failure) => <pod.ChatParticipantInfoDto>[],
                  (list) => list,
                );

                // 5. 메시지 조회 (초기 로드)
                final messagesResult = await getChatMessagesUseCase(
                  GetChatMessagesParams(
                    chatRoomId: chatRoomId,
                  ),
                );

                final messagesData = messagesResult.fold(
                  (failure) => (
                    messages: <pod.ChatMessageResponseDto>[],
                    pagination: null as pod.PaginatedChatMessagesResponseDto?,
                  ),
                  (pagination) => (
                    messages: pagination.messages,
                    pagination: pagination,
                  ),
                );

                // 6. 스트림 연결
                _connectMessageStream(chatRoomId);

                state = ChatLoaded(
                  chatRoom: chatRoom,
                  participants: participants,
                  messages: messagesData.messages,
                  pagination: messagesData.pagination,
                  isStreamConnected: true,
                );
              },
            );
          },
        );
      },
    );
  }

  /// 채팅방 ID로 직접 입장
  /// 채팅방 목록에서 기존 채팅방을 선택했을 때 호출
  Future<void> enterChatRoomByChatRoomId({
    required int chatRoomId,
  }) async {
    state = const ChatLoading();

    // 1. 채팅방 정보 조회
    final roomResult = await getChatRoomByIdUseCase(
      GetChatRoomByIdParams(chatRoomId: chatRoomId),
    );

    await roomResult.fold(
      (failure) async {
        state = ChatError(failure.message);
      },
      (chatRoom) async {
        if (chatRoom == null) {
          state = const ChatError('채팅방 정보를 찾을 수 없습니다.');
          return;
        }

        // 2. 채팅방 참여
        final joinResult = await joinChatRoomUseCase(
          JoinChatRoomParams(chatRoomId: chatRoomId),
        );

        await joinResult.fold(
          (failure) async {
            state = ChatError(failure.message);
          },
          (joinResponse) async {
            if (!joinResponse.success) {
              state = ChatError(joinResponse.message ?? '채팅방 참여에 실패했습니다.');
              return;
            }

            // 3. 참여자 목록 조회
            final participantsResult = await getChatParticipantsUseCase(
              GetChatParticipantsParams(chatRoomId: chatRoomId),
            );

            final participants = participantsResult.fold(
              (failure) => <pod.ChatParticipantInfoDto>[],
              (list) => list,
            );

            // 4. 메시지 조회 (초기 로드)
            final messagesResult = await getChatMessagesUseCase(
              GetChatMessagesParams(
                chatRoomId: chatRoomId,
              ),
            );

            final messagesData = messagesResult.fold(
              (failure) => (
                messages: <pod.ChatMessageResponseDto>[],
                pagination: null as pod.PaginatedChatMessagesResponseDto?,
              ),
              (pagination) => (
                messages: pagination.messages,
                pagination: pagination,
              ),
            );

            // 5. 스트림 연결
            _connectMessageStream(chatRoomId);

            state = ChatLoaded(
              chatRoom: chatRoom,
              participants: participants,
              messages: messagesData.messages,
              pagination: messagesData.pagination,
              isStreamConnected: true,
            );
          },
        );
      },
    );
  }

  /// 메시지 전송
  Future<void> sendMessage({
    required int chatRoomId,
    required String content,
    pod.MessageType messageType = pod.MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) async {
    final result = await sendMessageUseCase(
      SendMessageParams(
        chatRoomId: chatRoomId,
        content: content,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        attachmentSize: attachmentSize,
      ),
    );

    result.fold(
      (failure) {
        // 에러는 스낵바로 표시 (호출하는 곳에서 처리)
      },
      (message) {
        // 스트림을 통해 자동으로 수신되므로 별도 처리 불필요
      },
    );
  }

  /// 이전 메시지 로드 (페이지네이션)
  /// 채팅방에서는 위로 스크롤 시 이전 페이지(더 오래된 메시지)를 로드합니다.
  Future<void> loadMoreMessages(int chatRoomId) async {
    final currentState = state;
    if (currentState is! ChatLoaded || currentState is ChatLoadingMore) {
      return;
    }

    final pagination = currentState.pagination;
    // 채팅방은 위로 스크롤 시 이전 메시지를 로드하므로 hasPreviousPage 확인
    if (pagination == null || !pagination.hasPreviousPage) {
      return;
    }

    state = ChatLoadingMore(
      chatRoom: currentState.chatRoom,
      participants: currentState.participants,
      messages: currentState.messages,
      pagination: currentState.pagination,
      isStreamConnected: currentState.isStreamConnected,
    );

    final result = await getChatMessagesUseCase(
      GetChatMessagesParams(
        chatRoomId: chatRoomId,
        page: pagination.currentPage - 1, // 이전 페이지 로드
        limit: pagination.pageSize,
      ),
    );

    result.fold(
      (failure) {
        // 에러 발생 시 이전 상태로 복구
        state = currentState;
      },
      (newPagination) {
        // 기존 메시지에 새 메시지 추가 (중복 제거)
        final existingIds = currentState.messages.map((m) => m.id).toSet();
        final newMessages = newPagination.messages
            .where((m) => !existingIds.contains(m.id))
            .toList();

        state = ChatLoaded(
          chatRoom: currentState.chatRoom,
          participants: currentState.participants,
          messages: [...currentState.messages, ...newMessages],
          pagination: newPagination,
          isStreamConnected: currentState.isStreamConnected,
        );
      },
    );
  }

  // ==================== Public Methods (Service 호출) ====================

  // ==================== Private Helper Methods ====================

  /// 메시지 스트림 연결
  void _connectMessageStream(int chatRoomId) {
    // 기존 스트림 해제
    _messageStreamSubscription?.cancel();

    // 새 스트림 구독
    final stream = subscribeChatMessageStreamUseCase(
      SubscribeChatMessageStreamParams(chatRoomId: chatRoomId),
    );

    _messageStreamSubscription = stream.listen(
      (message) {
        // 실시간 메시지 수신
        final currentState = state;
        if (currentState is ChatLoaded) {
          // 중복 메시지 확인
          final existingIds = currentState.messages.map((m) => m.id).toSet();
          if (!existingIds.contains(message.id)) {
            state = currentState.copyWith(
              messages: [...currentState.messages, message],
            );
          }
        }
      },
      onError: (error) {
        // 에러 처리
        final currentState = state;
        if (currentState is ChatLoaded) {
          state = currentState.copyWith(isStreamConnected: false);
        }
      },
    );
  }

  @override
  void dispose() {
    _messageStreamSubscription?.cancel();
    super.dispose();
  }
}
