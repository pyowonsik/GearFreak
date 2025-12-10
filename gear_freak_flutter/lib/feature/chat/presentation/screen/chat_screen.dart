import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/view/view.dart';

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
  /// 카카오톡/당근마켓 방식: chatRoomId가 있으면 기존 채팅방으로 입장, 없으면 빈 상태로 유지
  Future<void> _loadChatRoom() async {
    // chatRoomId가 있으면 기존 채팅방으로 직접 입장
    if (widget.chatRoomId != null) {
      await ref.read(chatNotifierProvider.notifier).enterChatRoomByChatRoomId(
            chatRoomId: widget.chatRoomId!,
          );
      return;
    }

    // chatRoomId가 없으면 채팅방을 생성하지 않고 빈 상태로 유지
    // 첫 메시지 전송 시 채팅방이 생성됨 (카카오톡/당근마켓 방식)
    // 상품 정보만 로드
    final productId = int.tryParse(widget.productId);
    if (productId == null) {
      return;
    }

    // 상품 정보만 로드하여 표시
    await ref.read(chatNotifierProvider.notifier).loadProductInfo(
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

  /// ChatMessageResponseDto를 flutter_chat_types Message로 변환
  List<types.Message> _convertMessages(
    List<pod.ChatMessageResponseDto> messages,
    List<pod.ChatParticipantInfoDto> participants,
    int? currentUserId,
  ) {
    if (messages.isEmpty) {
      return [];
    }

    // notifier에서 이미 정렬되어 있으므로 추가 정렬 불필요
    return messages.map((message) {
      final senderId = message.senderId.toString();
      final isCurrentUser = currentUserId?.toString() == senderId;

      types.User author;
      if (isCurrentUser) {
        final authState = ref.read(authNotifierProvider);
        final user = authState is AuthAuthenticated ? authState.user : null;
        author = types.User(
          id: senderId,
          firstName: user?.nickname ?? '나',
          imageUrl: user?.profileImageUrl,
        );
      } else {
        final participant = participants.firstWhere(
          (p) => p.userId.toString() == senderId,
          orElse: () => participants.first,
        );
        author = types.User(
          id: senderId,
          firstName: participant.nickname ?? '사용자',
          imageUrl: participant.profileImageUrl,
        );
      }

      return types.TextMessage(
        author: author,
        createdAt: message.createdAt.millisecondsSinceEpoch,
        id: message.id.toString(),
        text: message.content,
      );
    }).toList();
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

    return Scaffold(
      appBar: _buildAppBar(chatState, currentUserId),
      body: _buildBody(chatState, currentUser, currentUserId),
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
            participants.isNotEmpty
                ? participants
                        .firstWhere(
                          (p) => p.userId != currentUserId,
                          orElse: () => participants.first,
                        )
                        .nickname ??
                    '사용자'
                : '사용자',
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
          chatRoom: _createDummyChatRoom(),
          messages: const [],
          participants: const [],
          pagination: null,
          product: product,
          currentUser: currentUser,
          currentUserId: currentUserId,
          isLoadingMore: false,
          onLoadMore: null,
          onSendPressed: _handleSendPressed,
          convertMessages: _convertMessages,
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
          onLoadMore: _chatRoomId != null
              ? () {
                  ref
                      .read(chatNotifierProvider.notifier)
                      .loadMoreMessages(_chatRoomId!);
                }
              : null,
          onSendPressed: _handleSendPressed,
          convertMessages: _convertMessages,
        ),
    };
  }

  /// 더미 채팅방 생성 (채팅방이 없을 때 UI 표시용)
  pod.ChatRoom _createDummyChatRoom() {
    final productId = int.tryParse(widget.productId) ?? 0;
    return pod.ChatRoom(
      productId: productId,
      chatRoomType: pod.ChatRoomType.direct,
      participantCount: 0,
      lastActivityAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
