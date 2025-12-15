import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/utils/chat_room_util.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/utils/chat_util.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/view/chat_loaded_view.dart';

/// 채팅 화면을 표시하는 위젯입니다.
///
/// 특정 채팅방의 메시지를 표시하고 새로운 메시지를 전송할 수 있습니다.
class ChatScreen extends ConsumerStatefulWidget {
  /// 채팅 화면을 생성합니다.
  ///
  /// [productId]는 상품 ID입니다. (채팅방 생성/조회에 사용)
  /// [sellerId]는 판매자 ID입니다. (기존 채팅방 찾기에 사용)
  /// [chatRoomId]는 채팅방 ID입니다. (기존 채팅방 입장 시 사용)
  const ChatScreen({
    required this.productId,
    this.sellerId,
    this.chatRoomId,
    super.key,
  });

  /// 상품 ID
  final String productId;

  /// 판매자 ID (기존 채팅방 찾기에 사용)
  final int? sellerId;

  /// 채팅방 ID (기존 채팅방 입장 시 사용)
  final int? chatRoomId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  int? _chatRoomId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatRoom();
    });
  }

  /// 채팅방 로드
  /// 1. chatRoomId가 있으면 기존 채팅방으로 직접 입장
  /// 2. chatRoomId가 없으면 기존 채팅방 확인
  ///    - 존재하면 이전 채팅 기록 로드
  ///    - 존재하지 않으면 빈 상태로 유지 (메시지 입력 시 방 생성)
  Future<void> _loadChatRoom() async {
    // chatRoomId가 있으면 기존 채팅방으로 직접 입장
    if (widget.chatRoomId != null) {
      await ref.read(chatNotifierProvider.notifier).enterChatRoomByChatRoomId(
            chatRoomId: widget.chatRoomId!,
          );
      return;
    }

    // chatRoomId가 없으면 기존 채팅방 확인
    final productId = int.tryParse(widget.productId);
    if (productId == null) {
      return;
    }

    // 기존 채팅방 확인 및 로드 (있으면 로드, 없으면 빈 상태)
    await ref.read(chatNotifierProvider.notifier).checkAndLoadExistingChatRoom(
          productId: productId,
          targetUserId: widget.sellerId,
        );
  }

  /// 메시지 전송
  /// 카카오톡/당근마켓 방식: 채팅방이 없으면 생성 후 메시지 전송
  void _handleSendPressed(types.PartialText message) {
    final state = ref.read(chatNotifierProvider);
    final productId = int.tryParse(widget.productId);
    final targetUserId = widget.sellerId;

    if (state is ChatLoaded) {
      // 기존 채팅방이 있으면 메시지만 전송
      ref.read(chatNotifierProvider.notifier).sendMessage(
            chatRoomId: state.chatRoom.id!,
            content: message.text,
          );
    } else if (state is ChatInitial && productId != null) {
      // 채팅방이 없으면 생성 후 메시지 전송
      ref.read(chatNotifierProvider.notifier).sendMessageWithoutChatRoom(
            productId: productId,
            targetUserId: targetUserId,
            content: message.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final authState = ref.read(authNotifierProvider);
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    // 현재 사용자 정보
    final currentUser = types.User(
      id: currentUserId?.toString() ?? 'unknown',
      firstName: authState is AuthAuthenticated
          ? (authState.user.nickname ?? '나')
          : '게스트',
      imageUrl: authState is AuthAuthenticated
          ? authState.user.profileImageUrl
          : null,
    );

    // chatRoomId 저장
    if (chatState is ChatLoaded) {
      _chatRoomId = chatState.chatRoom.id;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // 뒤로가기 시 읽음 처리
        if (didPop && _chatRoomId != null) {
          await ref
              .read(chatNotifierProvider.notifier)
              .markChatRoomAsRead(_chatRoomId!);
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(chatState, currentUserId),
        body: _buildBody(chatState, currentUser, currentUserId),
      ),
    );
  }

  /// AppBar 빌드
  PreferredSizeWidget? _buildAppBar(
    ChatState state,
    int? currentUserId,
  ) {
    return switch (state) {
      ChatLoaded(:final participants) ||
      ChatLoadingMore(:final participants) =>
        GbAppBar(
          title: Text(
            ChatRoomUtil.getOtherParticipantName(
              ref,
              participants: participants,
              defaultName: '사용자',
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: 더보기 메뉴
              },
            ),
          ],
        ),
      _ => const GbAppBar(
          title: Text('채팅'),
        ),
    };
  }

  /// Body 빌드
  Widget _buildBody(
    ChatState state,
    types.User currentUser,
    int? currentUserId,
  ) {
    return switch (state) {
      ChatLoading() => const GbLoadingView(),
      ChatError(:final message) => GbErrorView(
          message: message,
          onRetry: _loadChatRoom,
        ),
      ChatInitial(:final product) =>
        // 채팅방이 없는 상태에서도 채팅 입력 UI 표시 (카카오톡/당근마켓 방식)
        ChatLoadedView(
          chatRoom: ChatRoomUtil.createDummyChatRoom(
            int.tryParse(widget.productId) ?? 0,
          ),
          messages: const [],
          participants: const [],
          pagination: null,
          product: product,
          currentUser: currentUser,
          currentUserId: currentUserId,
          isLoadingMore: false,
          onLoadMore: null,
          onSendPressed: _handleSendPressed,
          convertMessages: (messages, participants, currentUserId) =>
              ChatUtil.convertChatMessages(
            messages,
            participants,
            currentUserId,
            ref,
          ),
        ),
      ChatLoaded(
        :final chatRoom,
        :final messages,
        :final participants,
        :final pagination,
        :final product,
      ) ||
      ChatLoadingMore(
        :final chatRoom,
        :final messages,
        :final participants,
        :final pagination,
        :final product,
      ) ||
      ChatImageUploading(
        :final chatRoom,
        :final messages,
        :final participants,
        :final pagination,
        :final product,
      ) ||
      ChatImageUploadError(
        :final chatRoom,
        :final messages,
        :final participants,
        :final pagination,
        :final product,
      ) =>
        ChatLoadedView(
          chatRoom: chatRoom,
          messages: messages,
          participants: participants,
          pagination: pagination,
          product: product,
          currentUser: currentUser,
          currentUserId: currentUserId,
          isLoadingMore: state is ChatLoadingMore,
          isImageUploading: state is ChatImageUploading,
          imageUploadError: switch (state) {
            ChatImageUploadError(:final error) => error,
            _ => null,
          },
          onLoadMore: _chatRoomId != null
              ? () {
                  ref
                      .read(chatNotifierProvider.notifier)
                      .loadMoreMessages(_chatRoomId!);
                }
              : null,
          onSendPressed: _handleSendPressed,
          convertMessages: (messages, participants, currentUserId) =>
              ChatUtil.convertChatMessages(
            messages,
            participants,
            currentUserId,
            ref,
          ),
        ),
    };
  }
}
