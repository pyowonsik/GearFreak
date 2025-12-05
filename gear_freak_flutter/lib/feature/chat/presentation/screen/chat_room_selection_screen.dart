import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_room_list_state.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/widget/chat_room_selection_item_widget.dart';
import 'package:go_router/go_router.dart';

/// 채팅방 선택 화면
class ChatRoomSelectionScreen extends ConsumerStatefulWidget {
  /// ChatRoomSelectionScreen 생성자
  const ChatRoomSelectionScreen({
    required this.productId,
    super.key,
  });

  /// 상품 ID
  final int productId;

  @override
  ConsumerState<ChatRoomSelectionScreen> createState() =>
      _ChatRoomSelectionScreenState();
}

class _ChatRoomSelectionScreenState
    extends ConsumerState<ChatRoomSelectionScreen> with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();
    initPaginationScroll(
      onLoadMore: () {
        ref
            .read(chatRoomListNotifierProvider.notifier)
            .loadMoreChatRoomsByProductId(widget.productId);
      },
      getPagination: () {
        final state = ref.read(chatRoomListNotifierProvider);
        if (state is ChatRoomListLoaded) {
          return state.pagination;
        }
        return null;
      },
      isLoading: () {
        final state = ref.read(chatRoomListNotifierProvider);
        return state is ChatRoomListLoadingMore;
      },
      screenName: 'ChatRoomSelectionScreen',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatRoomListNotifierProvider.notifier)
          .loadChatRoomsByProductId(widget.productId);
    });
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  /// 채팅방 목록 새로고침
  Future<void> _onRefresh() async {
    await ref
        .read(chatRoomListNotifierProvider.notifier)
        .loadChatRoomsByProductId(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomListState = ref.watch(chatRoomListNotifierProvider);

    return Scaffold(
      appBar: const GbAppBar(
        title: Text('대화중인 채팅'),
      ),
      body: switch (chatRoomListState) {
        ChatRoomListInitial() || ChatRoomListLoading() => const GbLoadingView(),
        ChatRoomListError(:final message) => GbErrorView(
            message: message,
            onRetry: () {
              ref
                  .read(chatRoomListNotifierProvider.notifier)
                  .loadChatRoomsByProductId(widget.productId);
            },
          ),
        ChatRoomListLoaded(:final chatRooms, :final pagination) ||
        ChatRoomListLoadingMore(:final chatRooms, :final pagination) =>
          chatRooms.isEmpty
              ? const GbEmptyView(
                  message: '채팅방이 없습니다',
                )
              : ChatRoomListLoadedView(
                  chatRoomList: chatRooms,
                  pagination: pagination,
                  scrollController: scrollController!,
                  isLoadingMore: chatRoomListState is ChatRoomListLoadingMore,
                  onRefresh: _onRefresh,
                  itemBuilder: (context, chatRoom) {
                    return ChatRoomSelectionItemWidget(
                      chatRoom: chatRoom,
                      onTap: () {
                        Navigator.pop(context);
                        context.push(
                          '/chat/${widget.productId}?chatRoomId=${chatRoom.id}',
                        );
                      },
                    );
                  },
                ),
      },
    );
  }
}
