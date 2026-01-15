import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/notification/domain/usecase/delete_notification_usecase.dart';
import 'package:gear_freak_flutter/feature/notification/domain/usecase/get_notifications_usecase.dart';
import 'package:gear_freak_flutter/feature/notification/domain/usecase/get_unread_count_usecase.dart';
import 'package:gear_freak_flutter/feature/notification/domain/usecase/mark_as_read_usecase.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/provider/notification_list_state.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/check_review_exists_usecase.dart';
import 'package:gear_freak_flutter/shared/service/badge_service.dart';
import 'package:gear_freak_flutter/shared/service/notification_cancel_service.dart';

/// 알림 목록 Notifier
class NotificationListNotifier extends StateNotifier<NotificationListState> {
  /// NotificationListNotifier 생성자
  NotificationListNotifier(
    this.ref,
    this.getNotificationsUseCase,
    this.markAsReadUseCase,
    this.deleteNotificationUseCase,
    this.checkReviewExistsUseCase,
    this.getUnreadCountUseCase,
  ) : super(const NotificationListInitial());

  /// Riverpod Ref 인스턴스
  final Ref ref;

  /// 알림 목록 조회 UseCase
  final GetNotificationsUseCase getNotificationsUseCase;

  /// 알림 읽음 처리 UseCase
  final MarkAsReadUseCase markAsReadUseCase;

  /// 알림 삭제 UseCase
  final DeleteNotificationUseCase deleteNotificationUseCase;

  /// 리뷰 존재 여부 확인 UseCase
  final CheckReviewExistsUseCase checkReviewExistsUseCase;

  /// 읽지 않은 알림 개수 조회 UseCase
  final GetUnreadCountUseCase getUnreadCountUseCase;

  /// 알림 목록 로드
  Future<void> loadNotifications({int page = 1, int limit = 20}) async {
    state = const NotificationListLoading();

    final result = await getNotificationsUseCase(
      GetNotificationsParams(page: page, limit: limit),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [NotificationListNotifier] 알림 목록 로드 실패:'
            ' ${failure.message}');
        state = NotificationListError(failure.message);
      },
      (response) {
        debugPrint('✅ [NotificationListNotifier] 알림 목록 로드 성공: '
            'page=${response.pagination.page}, '
            'totalCount=${response.pagination.totalCount}, '
            'hasMore=${response.pagination.hasMore}, '
            'notifications=${response.notifications.length}개, '
            'unreadCount=${response.unreadCount}');
        state = NotificationListLoaded(
          notifications: response.notifications,
          pagination: response.pagination,
          unreadCount: response.unreadCount,
        );
      },
    );
  }

  /// 더 많은 알림 불러오기
  Future<void> loadMoreNotifications() async {
    final currentState = state;

    if (currentState is! NotificationListLoaded) {
      debugPrint('⚠️ [NotificationListNotifier] loadMoreNotifications: '
          '현재 상태가 NotificationListLoaded가 아닙니다. '
          '(${currentState.runtimeType})');
      return;
    }

    final currentPagination = currentState.pagination;

    if (currentPagination.hasMore != true) {
      debugPrint('⚠️ [NotificationListNotifier] loadMoreNotifications:'
          ' 더 이상 불러올 데이터가 없습니다.');
      return;
    }

    if (state is NotificationListLoadingMore) {
      debugPrint('⚠️ [NotificationListNotifier] loadMoreNotifications:'
          ' 이미 로딩 중입니다.');
      return;
    }

    final nextPage = currentPagination.page + 1;
    debugPrint('🔄 [NotificationListNotifier] 다음 페이지 로드: page=$nextPage '
        '(현재: ${currentPagination.page}, '
        '전체: ${currentPagination.totalCount})');

    state = NotificationListLoadingMore(
      notifications: currentState.notifications,
      pagination: currentPagination,
      unreadCount: currentState.unreadCount,
    );

    final result = await getNotificationsUseCase(
      GetNotificationsParams(
        page: nextPage,
        limit: currentPagination.limit,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [NotificationListNotifier] 다음 페이지 로드 실패:'
            ' ${failure.message}');
        state = currentState;
      },
      (response) {
        final updatedNotifications = [
          ...currentState.notifications,
          ...response.notifications,
        ];

        debugPrint('✅ [NotificationListNotifier] 다음 페이지 로드 성공: '
            'page=${response.pagination.page}, '
            '추가된 알림=${response.notifications.length}개, '
            '총 알림=${updatedNotifications.length}개, '
            'hasMore=${response.pagination.hasMore}');

        state = NotificationListLoaded(
          notifications: updatedNotifications,
          pagination: response.pagination,
          unreadCount: response.unreadCount,
        );
      },
    );
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(int notificationId) async {
    final result = await markAsReadUseCase(
      MarkAsReadParams(notificationId: notificationId),
    );

    await result.fold(
      (failure) {
        debugPrint('❌ [NotificationListNotifier] 알림 읽음 처리 실패:'
            ' ${failure.message}');
      },
      (success) async {
        debugPrint('✅ [NotificationListNotifier] 알림 읽음 처리 성공: '
            'notificationId=$notificationId');
        // 현재 상태 업데이트
        final currentState = state;
        if (currentState is NotificationListLoaded) {
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == notificationId) {
              return pod.NotificationResponseDto(
                id: n.id,
                notificationType: n.notificationType,
                title: n.title,
                body: n.body,
                data: n.data,
                isRead: true,
                readAt: DateTime.now(),
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();

          // unreadCount 감소
          final newUnreadCount =
              currentState.unreadCount > 0 ? currentState.unreadCount - 1 : 0;

          state = NotificationListLoaded(
            notifications: updatedNotifications,
            pagination: currentState.pagination,
            unreadCount: newUnreadCount,
          );
        } else if (currentState is NotificationListLoadingMore) {
          final updatedNotifications = currentState.notifications.map((n) {
            if (n.id == notificationId) {
              return pod.NotificationResponseDto(
                id: n.id,
                notificationType: n.notificationType,
                title: n.title,
                body: n.body,
                data: n.data,
                isRead: true,
                readAt: DateTime.now(),
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();

          final newUnreadCount =
              currentState.unreadCount > 0 ? currentState.unreadCount - 1 : 0;

          state = NotificationListLoadingMore(
            notifications: updatedNotifications,
            pagination: currentState.pagination,
            unreadCount: newUnreadCount,
          );
        }

        // Android: 알림 트레이에서 알림 취소
        await NotificationCancelService.instance.cancelAllNotifications();

        // Provider 무효화 후 앱 아이콘 배지 업데이트
        await BadgeService.instance.invalidateAndUpdateBadge(ref);
      },
    );
  }

  /// 알림 삭제
  Future<void> deleteNotification(int notificationId) async {
    final result = await deleteNotificationUseCase(
      DeleteNotificationParams(notificationId: notificationId),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [NotificationListNotifier] 알림 삭제 실패: ${failure.message}');
      },
      (success) {
        debugPrint('✅ [NotificationListNotifier] 알림 삭제 성공: '
            'notificationId=$notificationId');
        // 현재 상태에서 알림 제거
        final currentState = state;
        if (currentState is NotificationListLoaded) {
          final deletedNotification = currentState.notifications
              .firstWhere((n) => n.id == notificationId);
          final updatedNotifications = currentState.notifications
              .where((n) => n.id != notificationId)
              .toList();

          // unreadCount 업데이트 (삭제된 알림이 읽지 않았으면 감소)
          final newUnreadCount =
              !deletedNotification.isRead && currentState.unreadCount > 0
                  ? currentState.unreadCount - 1
                  : currentState.unreadCount;

          state = NotificationListLoaded(
            notifications: updatedNotifications,
            pagination: currentState.pagination,
            unreadCount: newUnreadCount,
          );
        } else if (currentState is NotificationListLoadingMore) {
          final deletedNotification = currentState.notifications
              .firstWhere((n) => n.id == notificationId);
          final updatedNotifications = currentState.notifications
              .where((n) => n.id != notificationId)
              .toList();

          final newUnreadCount =
              !deletedNotification.isRead && currentState.unreadCount > 0
                  ? currentState.unreadCount - 1
                  : currentState.unreadCount;

          state = NotificationListLoadingMore(
            notifications: updatedNotifications,
            pagination: currentState.pagination,
            unreadCount: newUnreadCount,
          );
        }
      },
    );
  }

  /// 리뷰 존재 여부 확인 (양쪽 모두 확인)
  /// 반환: (구매자 리뷰 존재 여부, 판매자 리뷰 존재 여부)
  Future<(bool buyerReviewExists, bool sellerReviewExists)> checkReviewExists({
    required int productId,
    required int chatRoomId,
  }) async {
    // 구매자 리뷰 확인 (buyer_to_seller: 구매자가 판매자에게)
    final buyerReviewResult = await checkReviewExistsUseCase(
      CheckReviewExistsParams(
        productId: productId,
        chatRoomId: chatRoomId,
        reviewType: pod.ReviewType.buyer_to_seller,
      ),
    );

    // 판매자 리뷰 확인 (seller_to_buyer: 판매자가 구매자에게)
    final sellerReviewResult = await checkReviewExistsUseCase(
      CheckReviewExistsParams(
        productId: productId,
        chatRoomId: chatRoomId,
        reviewType: pod.ReviewType.seller_to_buyer,
      ),
    );

    var buyerReviewExists = false;
    var sellerReviewExists = false;

    buyerReviewResult.fold(
      (failure) {
        debugPrint('❌ [NotificationListNotifier] 구매자 리뷰 존재 여부 확인 실패:'
            ' ${failure.message}');
      },
      (exists) {
        buyerReviewExists = exists;
      },
    );

    sellerReviewResult.fold(
      (failure) {
        debugPrint('❌ [NotificationListNotifier] 판매자 리뷰 존재 여부 확인 실패:'
            ' ${failure.message}');
      },
      (exists) {
        sellerReviewExists = exists;
      },
    );

    return (buyerReviewExists, sellerReviewExists);
  }

  /// 읽지 않은 알림 개수만 조회 (알림 목록을 로드하지 않음)
  ///
  /// @deprecated Use totalUnreadNotificationCountProvider instead
  /// 이 메서드는 더 이상 사용되지 않습니다.
  /// 대신 totalUnreadNotificationCountProvider를 사용하세요.
  @Deprecated('Use totalUnreadNotificationCountProvider instead')
  Future<void> loadUnreadCount() async {
    final result = await getUnreadCountUseCase(null);

    result.fold(
      (failure) {
        debugPrint('❌ [NotificationListNotifier] 읽지 않은 알림 개수 조회 실패:'
            ' ${failure.message}');
      },
      (count) {
        debugPrint('✅ [NotificationListNotifier] 읽지 않은 알림 개수 조회 성공: $count');
        // 현재 상태에 따라 unreadCount 업데이트
        final currentState = state;
        if (currentState is NotificationListLoaded) {
          state = currentState.copyWith(unreadCount: count);
        } else if (currentState is NotificationListLoadingMore) {
          state = NotificationListLoadingMore(
            notifications: currentState.notifications,
            pagination: currentState.pagination,
            unreadCount: count,
          );
        }
        // 로딩 상태나 에러 상태인 경우에는 상태를 변경하지 않음
        // (알림 목록을 로드할 때 unreadCount가 함께 업데이트됨)
      },
    );
  }
}
