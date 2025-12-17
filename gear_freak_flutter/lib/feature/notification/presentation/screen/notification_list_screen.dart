import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/notification/di/notification_providers.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/provider/notification_list_state.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/widget/notification_item_widget.dart';

/// 알림 리스트 화면
/// Presentation Layer: UI
class NotificationListScreen extends ConsumerStatefulWidget {
  /// NotificationListScreen 생성자
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState extends ConsumerState<NotificationListScreen>
    with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [NotificationListScreen] initState 호출');

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔄 [NotificationListScreen] 데이터 로드 시작');
      ref.read(notificationListNotifierProvider.notifier).loadNotifications();

      // 페이지네이션 초기화
      initPaginationScroll(
        onLoadMore: () {
          debugPrint('🔥 [NotificationList] onLoadMore 호출됨!');
          ref
              .read(notificationListNotifierProvider.notifier)
              .loadMoreNotifications();
        },
        getPagination: () {
          final state = ref.read(notificationListNotifierProvider);
          if (state is NotificationListLoaded) {
            debugPrint(
                '📊 [NotificationList] Pagination: page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}, totalCount=${state.pagination.totalCount}');
            return state.pagination;
          }
          if (state is NotificationListLoadingMore) {
            debugPrint(
                '📊 [NotificationList] LoadingMore: page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}');
            return state.pagination;
          }
          debugPrint('⚠️ [NotificationList] Pagination is null, state: $state');
          return null;
        },
        isLoading: () {
          final state = ref.read(notificationListNotifierProvider);
          final loading = state is NotificationListLoadingMore;
          debugPrint('🔄 [NotificationList] isLoading: $loading');
          return loading;
        },
        screenName: 'NotificationListScreen',
      );
      debugPrint(
          '📋 [NotificationListScreen] scrollController 생성됨: $scrollController');
    });
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListNotifierProvider);
    debugPrint(
        '🎨 [NotificationListScreen] build, state: ${state.runtimeType}, '
        'scrollController: $scrollController');

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
      ),
      body: switch (state) {
        NotificationListInitial() ||
        NotificationListLoading() =>
          const GbLoadingView(),
        NotificationListError(:final message) => GbErrorView(
            message: message,
            onRetry: () {
              ref
                  .read(notificationListNotifierProvider.notifier)
                  .loadNotifications();
            },
          ),
        NotificationListLoaded(:final notifications) ||
        NotificationListLoadingMore(:final notifications) =>
          notifications.isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(notificationListNotifierProvider.notifier)
                        .loadNotifications();
                  },
                  child: const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_outlined,
                              size: 80,
                              color: Color(0xFFE5E7EB),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '알림이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : _NotificationListView(
                  notifications: notifications,
                  isLoadingMore: state is NotificationListLoadingMore,
                  scrollController: scrollController,
                  onRefresh: () async {
                    await ref
                        .read(notificationListNotifierProvider.notifier)
                        .loadNotifications();
                  },
                  onNotificationTap: (notification) {
                    _handleNotificationTap(context, notification);
                  },
                  onNotificationDelete: (notificationId) {
                    ref
                        .read(notificationListNotifierProvider.notifier)
                        .deleteNotification(notificationId);
                  },
                ),
      },
    );
  }

  /// 알림 탭 처리 (딥링크 네비게이션)
  void _handleNotificationTap(
    BuildContext context,
    pod.NotificationResponseDto notification,
  ) {
    final data = notification.data;
    if (data == null || data.isEmpty) {
      return;
    }

    // 후기 받음 알림인 경우
    if (notification.notificationType == pod.NotificationType.review_received &&
        data['productId'] != null &&
        data['reviewerId'] != null &&
        data['chatRoomId'] != null) {
      final productId = data['productId'];
      final reviewerId = data['reviewerId'];
      final chatRoomId = data['chatRoomId'];

      debugPrint(
          '🔗 판매자 리뷰 작성 화면으로 이동: productId=$productId, reviewerId=$reviewerId, chatRoomId=$chatRoomId');

      // 읽음 처리
      ref
          .read(notificationListNotifierProvider.notifier)
          .markAsRead(notification.id);

      // 리뷰 작성 화면으로 이동
      context.push(
          '/product/$productId/review/write?revieweeId=$reviewerId&chatRoomId=$chatRoomId&isSellerReview=true');
    }
  }
}

/// 알림 목록 뷰
class _NotificationListView extends StatelessWidget {
  const _NotificationListView({
    required this.notifications,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onNotificationTap,
    required this.onNotificationDelete,
    this.scrollController,
  });

  final List<pod.NotificationResponseDto> notifications;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final void Function(pod.NotificationResponseDto) onNotificationTap;
  final void Function(int) onNotificationDelete;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '📱 [_NotificationListView] build, notifications: ${notifications.length}, '
        'isLoadingMore: $isLoadingMore, scrollController: $scrollController');
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notifications.length,
        separatorBuilder: (context, index) {
          return const Divider(
            height: 1,
            thickness: 8,
            color: Color(0xFFF3F4F6),
          );
        },
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItemWidget(
            notification: notification,
            onTap: () => onNotificationTap(notification),
            onDelete: () => onNotificationDelete(notification.id),
          );
        },
      ),
    );
  }
}
