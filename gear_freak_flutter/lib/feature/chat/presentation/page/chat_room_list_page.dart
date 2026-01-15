import 'dart:async';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/core/util/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/presentation.dart';
import 'package:gear_freak_flutter/feature/notification/di/notification_providers.dart';
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
      if (!mounted) return;

      ref.read(chatRoomListNotifierProvider.notifier).loadChatRooms();

      // FCM 메시지 수신 시 채팅방 리스트 갱신
      FcmService.instance.setOnMessageReceived((chatRoomId, badge) async {
        if (!mounted) return;

        // 읽지 않은 채팅 개수 갱신 (BottomNavigationBar Badge 업데이트)
        // ignore: unused_result
        ref.refresh(totalUnreadChatCountProvider);

        // 서버에서 보낸 badge 값이 있으면 즉시 앱 배지 업데이트
        await _updateBadgeFromFcm(badge);

        // 포그라운드에서 FCM 메시지를 받으면 채팅방 리스트 갱신
        if (!mounted) return;
        unawaited(
          ref
              .read(chatRoomListNotifierProvider.notifier)
              .refreshChatRoomInfo(chatRoomId),
        );
      });
    });

    // 앱 생명주기 감지 (백그라운드 -> 포그라운드)
    // main.dart에서 이미 totalUnreadChatCountProvider를 갱신하므로 여기서는 채팅방 목록만 갱신
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        // 백그라운드에서 포그라운드로 돌아올 때 채팅방 리스트 새로고침
        if (state == AppLifecycleState.resumed) {
          if (!mounted) return;
          ref.read(chatRoomListNotifierProvider.notifier).loadChatRooms();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    disposePaginationScroll();

    // 채팅 탭을 나갈 때 FCM 콜백을 기본 콜백으로 리셋
    // dispose 후 ref를 사용하지 않도록 main.dart의 전역 콜백을 직접 설정
    // (main.dart의 _MyAppState._refreshUnreadCount와 동일한 로직)
    FcmService.instance.setOnMessageReceived((chatRoomId, badge) async {
      // 기본 동작: badge 값이 있으면 즉시 앱 배지 업데이트
      // 주의: 여기서는 ref를 사용할 수 없으므로 배지만 업데이트
      // main.dart의 전역 AppLifecycleListener가 백그라운드 복귀 시 갱신함
      if (badge != null) {
        debugPrint(
          '📛 [ChatRoomListPage dispose] FCM badge 즉시 업데이트: $badge',
        );
        await AppBadgePlus.updateBadge(badge);
      }
    });

    super.dispose();
  }

  /// FCM badge 값으로 앱 배지 업데이트
  Future<void> _updateBadgeFromFcm(int? badge) async {
    if (!mounted) return;

    if (badge != null) {
      debugPrint('📛 [ChatRoomListPage] FCM badge 값으로 즉시 업데이트: $badge');
      await AppBadgePlus.updateBadge(badge);
    } else {
      // badge가 null이면 로컬에서 계산 (+1은 새 채팅)
      debugPrint('⚠️ [ChatRoomListPage] FCM badge null, 로컬 계산');
      try {
        final chatCount = await ref.read(totalUnreadChatCountProvider.future);
        final notificationCount =
            await ref.read(totalUnreadNotificationCountProvider.future);
        final localBadge = chatCount + notificationCount + 1;
        debugPrint('📛 [ChatRoomListPage] 로컬 badge: $localBadge');
        await AppBadgePlus.updateBadge(localBadge);
      } catch (e) {
        debugPrint('⚠️ [ChatRoomListPage] 로컬 badge 계산 실패: $e');
      }
    }
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
