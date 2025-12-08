import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_room_list_state.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/view/view.dart';

/// 채팅방 목록 화면
/// Presentation Layer: UI
class ChatRoomListScreen extends ConsumerStatefulWidget {
  /// ChatRoomListScreen 생성자
  const ChatRoomListScreen({super.key});

  @override
  ConsumerState<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends ConsumerState<ChatRoomListScreen>
    with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();
    initPaginationScroll(
      onLoadMore: () {
        ref.read(chatRoomListNotifierProvider.notifier).loadMoreChatRooms();
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
      screenName: 'ChatRoomListScreen',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomListNotifierProvider.notifier).loadChatRooms();
    });
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  /// 채팅방 목록 새로고침
  Future<void> _onRefresh() async {
    await ref.read(chatRoomListNotifierProvider.notifier).loadChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomListState = ref.watch(chatRoomListNotifierProvider);

    return Scaffold(
      appBar: const GbAppBar(
        title: Text('채팅'),
      ),
      body: _buildBody(chatRoomListState),
    );
  }

  Widget _buildBody(ChatRoomListState state) {
    return switch (state) {
      ChatRoomListInitial() || ChatRoomListLoading() => const GbLoadingView(),
      ChatRoomListError(:final message) => GbErrorView(
          message: '에러: $message',
          onRetry: () {
            ref.read(chatRoomListNotifierProvider.notifier).loadChatRooms();
          },
        ),
      ChatRoomListLoaded(
        :final chatRooms,
        :final pagination,
        :final participantsMap,
        :final lastMessagesMap
      ) ||
      ChatRoomListLoadingMore(
        :final chatRooms,
        :final pagination,
        :final participantsMap,
        :final lastMessagesMap
      ) =>
        chatRooms.isEmpty
            ? const GbEmptyView(
                message: '채팅방이 없습니다',
              )
            : ChatRoomListLoadedView(
                chatRoomList: chatRooms,
                pagination: pagination,
                scrollController: scrollController!,
                isLoadingMore: state is ChatRoomListLoadingMore,
                onRefresh: _onRefresh,
                participantsMap: participantsMap,
                lastMessagesMap: lastMessagesMap,
              ),
    };
  }
}
