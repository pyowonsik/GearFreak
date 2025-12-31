import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/core/util/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/presentation.dart';
import 'package:gear_freak_flutter/shared/service/fcm_service.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';

/// 채팅방 목록 화면
/// Presentation Layer: UI
class ChatRoomListPage extends ConsumerStatefulWidget {
  /// ChatRoomListPage 생성자
  const ChatRoomListPage({super.key});

  @override
  ConsumerState<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends ConsumerState<ChatRoomListPage>
    with PaginationScrollMixin {
  AppLifecycleListener? _lifecycleListener;

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
      screenName: 'ChatRoomListPage',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomListNotifierProvider.notifier).loadChatRooms();

      // FCM 메시지 수신 시 채팅방 리스트 갱신
      FcmService.instance.setOnMessageReceived((chatRoomId) {
        // 포그라운드에서 FCM 메시지를 받으면 채팅방 리스트 갱신
        ref
            .read(chatRoomListNotifierProvider.notifier)
            .refreshChatRoomInfo(chatRoomId);
      });
    });

    // 앱 생명주기 감지 (백그라운드 -> 포그라운드)
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        // 백그라운드에서 포그라운드로 돌아올 때 채팅방 리스트 새로고침
        if (state == AppLifecycleState.resumed) {
          ref.read(chatRoomListNotifierProvider.notifier).loadChatRooms();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
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
      body: switch (chatRoomListState) {
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
          :final lastMessagesMap,
          :final productImagesMap
        ) ||
        ChatRoomListLoadingMore(
          :final chatRooms,
          :final pagination,
          :final participantsMap,
          :final lastMessagesMap,
          :final productImagesMap
        ) =>
          chatRooms.isEmpty
              ? RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          MediaQuery.of(context).padding.top,
                      child: const GbEmptyView(
                        message: '채팅방이 없습니다',
                      ),
                    ),
                  ),
                )
              : ChatRoomListLoadedView(
                  chatRoomList: chatRooms,
                  pagination: pagination,
                  scrollController: scrollController!,
                  isLoadingMore: chatRoomListState is ChatRoomListLoadingMore,
                  onRefresh: _onRefresh,
                  participantsMap: participantsMap,
                  lastMessagesMap: lastMessagesMap,
                  productImagesMap: productImagesMap,
                ),
      },
    );
  }
}
