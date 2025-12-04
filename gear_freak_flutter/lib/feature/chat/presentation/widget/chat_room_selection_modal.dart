import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_room_list_state.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/widget/chat_room_selection_item_widget.dart';

/// 채팅방 선택 모달
class ChatRoomSelectionModal extends ConsumerStatefulWidget {
  /// ChatRoomSelectionModal 생성자
  const ChatRoomSelectionModal({
    required this.productId,
    super.key,
  });

  /// 상품 ID
  final int productId;

  /// 모달 표시
  static Future<void> show(BuildContext context, int productId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatRoomSelectionModal(productId: productId),
    );
  }

  @override
  ConsumerState<ChatRoomSelectionModal> createState() =>
      _ChatRoomSelectionModalState();
}

class _ChatRoomSelectionModalState extends ConsumerState<ChatRoomSelectionModal>
    with PaginationScrollMixin {
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
      screenName: 'ChatRoomSelectionModal',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '채팅방 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // 채팅방 리스트
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final chatRoomListState = ref.watch(chatRoomListNotifierProvider);

    return switch (chatRoomListState) {
      ChatRoomListInitial() || ChatRoomListLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
      ChatRoomListError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('에러: $message'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(chatRoomListNotifierProvider.notifier)
                      .loadChatRoomsByProductId(widget.productId);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ChatRoomListLoaded(:final chatRooms, :final pagination) ||
      ChatRoomListLoadingMore(:final chatRooms, :final pagination) =>
        chatRooms.isEmpty
            ? const GbEmptyView(
                message: '채팅방이 없습니다',
              )
            : Builder(
                builder: (context) {
                  final isLoadingMoreState =
                      chatRoomListState is ChatRoomListLoadingMore;
                  // isLoadingMore이면 항상 마지막에 로딩 인디케이터 표시
                  // 아니면 hasMore일 때만 표시
                  final itemCount = isLoadingMoreState
                      ? chatRooms.length + 1
                      : chatRooms.length +
                          ((pagination.hasMore ?? false) ? 1 : 0);

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index == chatRooms.length) {
                        // 마지막에 로딩 인디케이터 표시
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: isLoadingMoreState
                                ? const CircularProgressIndicator()
                                : const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                          ),
                        );
                      }
                      final chatRoom = chatRooms[index];
                      return ChatRoomSelectionItemWidget(
                        chatRoom: chatRoom,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: 채팅방으로 이동 - productId와 chatRoomId를 전달해야 함
                          // context.push('/chat/${widget.productId}?chatRoomId=${chatRoom.id}');
                        },
                      );
                    },
                  );
                },
              ),
    };
  }
}
