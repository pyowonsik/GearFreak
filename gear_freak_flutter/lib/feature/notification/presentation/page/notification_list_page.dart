import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/core/util/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/presentation.dart';
import 'package:gear_freak_flutter/feature/notification/di/notification_providers.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/presentation.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';
import 'package:go_router/go_router.dart';

/// 알림 리스트 화면
/// Presentation Layer: UI
class NotificationListPage extends ConsumerStatefulWidget {
  /// NotificationListPage 생성자
  const NotificationListPage({super.key});

  @override
  ConsumerState<NotificationListPage> createState() =>
      _NotificationListPageState();
}

class _NotificationListPageState extends ConsumerState<NotificationListPage>
    with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [NotificationListPage] initState 호출');

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔄 [NotificationListPage] 데이터 로드 시작');
      unawaited(
        ref.read(notificationListNotifierProvider.notifier).loadNotifications(),
      );

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
            debugPrint('📊 [NotificationList] Pagination: '
                'page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}, '
                'totalCount=${state.pagination.totalCount}');
            return state.pagination;
          }
          if (state is NotificationListLoadingMore) {
            debugPrint('📊 [NotificationList] LoadingMore: '
                'page=${state.pagination.page}, '
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
        screenName: 'NotificationListPage',
      );
      debugPrint('📋 [NotificationListPage] '
          'scrollController 생성됨: $scrollController');
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
    debugPrint('🎨 [NotificationListPage] build, state: ${state.runtimeType}, '
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
              : NotificationListLoadedView(
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
                    unawaited(
                      ref
                          .read(notificationListNotifierProvider.notifier)
                          .deleteNotification(notificationId),
                    );
                  },
                ),
      },
    );
  }

  /// 알림 탭 처리 (딥링크 네비게이션)
  Future<void> _handleNotificationTap(
    BuildContext context,
    pod.NotificationResponseDto notification,
  ) async {
    final data = notification.data;
    if (data == null || data.isEmpty) {
      return;
    }

    // 후기 받음 알림인 경우
    if (notification.notificationType == pod.NotificationType.review_received &&
        data['productId'] != null &&
        data['reviewerId'] != null &&
        data['chatRoomId'] != null) {
      final productId = int.tryParse(data['productId'].toString());
      final reviewerId = int.tryParse(data['reviewerId'].toString());
      final chatRoomId = int.tryParse(data['chatRoomId'].toString());

      if (productId == null || reviewerId == null || chatRoomId == null) {
        return;
      }

      // 현재 사용자 ID 가져오기
      final authState = ref.read(authNotifierProvider);
      final currentUserId =
          authState is AuthAuthenticated ? authState.user.id : null;

      if (currentUserId == null) {
        debugPrint('⚠️ 현재 사용자 ID를 가져올 수 없습니다.');
        return;
      }

      // 알림을 받은 사람(현재 사용자)이 리뷰를 작성해야 함
      // reviewerId는 리뷰를 작성한 사람(알림을 보낸 사람)
      // 현재 사용자는 reviewerId에게 리뷰를 작성해야 함
      final revieweeId = reviewerId; // 리뷰를 작성할 대상

      // 리뷰 타입 결정: 현재 사용자가 판매자인지 구매자인지 확인
      // 알림 데이터의 revieweeId는 알림을 받은 사람(현재 사용자)
      // notification.userId == currentUserId (알림을 받은 사람)
      // reviewerId는 리뷰를 작성한 사람 (현재 사용자가 리뷰를 작성할 대상)

      // 판매자가 구매자에게 리뷰 작성 (seller_to_buyer) → 구매자가 알림 받음
      // → 구매자가 판매자에게 리뷰 작성 (buyer_to_seller)
      // 구매자가 판매자에게 리뷰 작성 (buyer_to_seller) → 판매자가 알림 받음
      // → 판매자가 구매자에게 리뷰 작성 (seller_to_buyer)

      // 알림을 받은 사람이 작성할 리뷰 타입 결정
      // notification.userId는 알림을 받은 사람 = 현재 사용자
      // reviewerId는 리뷰를 작성한 사람 = 현재 사용자가 리뷰를 작성할 대상
      // 현재 사용자가 작성할 리뷰 타입은 알림을 받은 사람의 역할에 따라 결정됨
      // 하지만 알림 데이터만으로는 판매자/구매자 구분이 어려움
      // 따라서 양쪽 모두 확인해야 함

      debugPrint('🔗 리뷰 작성 화면으로 이동: '
          'productId=$productId, '
          'reviewerId=$reviewerId, '
          'revieweeId=$revieweeId, '
          'chatRoomId=$chatRoomId, '
          'currentUserId=$currentUserId');

      // 읽음 처리
      await ref
          .read(notificationListNotifierProvider.notifier)
          .markAsRead(notification.id);

      // 리뷰 존재 여부 확인 (양쪽 모두 확인) - Notifier를 통해 처리
      final (buyerReviewExists, sellerReviewExists) = await ref
          .read(notificationListNotifierProvider.notifier)
          .checkReviewExists(
            productId: productId,
            chatRoomId: chatRoomId,
          );

      if (!mounted) return;

      // 알림 탭 시 리뷰 작성 규칙:
      // 1. 구매자 리뷰(buyer_to_seller)는 상품 상태 변경 시에만 작성 가능
      // 2. 알림 탭 시에는 판매자 리뷰(seller_to_buyer)만 작성 가능
      //
      // 시나리오:
      // - 판매자가 구매자에게 리뷰 작성 (seller_to_buyer) → 구매자가 알림 받음
      //   → 구매자는 판매자에게 리뷰를 작성해야 하지만, 알림으로는 작성 불가
      //   → "이미 작성한 화면"으로 이동 (구매자 리뷰는 상품 상태 변경 시에만 작성 가능)
      // - 구매자가 판매자에게 리뷰 작성 (buyer_to_seller) → 판매자가 알림 받음
      //   → 판매자는 구매자에게 리뷰 작성 가능 (seller_to_buyer)
      //   → 판매자 리뷰가 이미 작성되어 있으면 "이미 작성한 화면"으로 이동

      if (sellerReviewExists) {
        // 판매자 리뷰가 이미 작성되어 있음
        // → 판매자가 구매자에게 리뷰를 작성했다는 의미
        // → 구매자가 알림을 받았으므로, 구매자는 "판매자가 나에게 남긴 리뷰"를 봐야 함
        // → 리뷰 목록 화면의 "판매자 후기" 탭으로 이동 (인덱스 1)
        context.push('/profile/reviews?tabIndex=1');
      } else if (buyerReviewExists && !sellerReviewExists) {
        // 구매자 리뷰는 작성됨, 판매자 리뷰는 아직 안 됨
        // → 구매자가 판매자에게 리뷰 작성 (buyer_to_seller) → 판매자가 알림 받음
        // → 판매자는 "구매자가 나에게 남긴 리뷰"를 봐야 함
        // → 리뷰 목록 화면의 "구매자 후기" 탭으로 이동 (인덱스 0)
        context.push('/profile/reviews?tabIndex=0');
      } else {
        // 판매자 리뷰가 없고 구매자 리뷰도 없는 경우
        // → 판매자가 구매자에게 리뷰 작성 (seller_to_buyer)
        // (구매자 리뷰는 상품 상태 변경 시에만 작성 가능하므로 알림으로는 작성 불가)
        final result = await context.push<bool>(
          '/product/$productId/review/write?revieweeId=$revieweeId&chatRoomId=$chatRoomId&isSellerReview=true',
        );

        // 리뷰 작성 완료 후 돌아온 경우 알림 목록 새로고침
        if ((result ?? false) && mounted) {
          await ref
              .read(notificationListNotifierProvider.notifier)
              .loadNotifications();
        }
      }
    }
  }
}
