import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';

/// 알림 원격 데이터 소스
/// Data Layer: API 호출
class NotificationRemoteDataSource {
  /// NotificationRemoteDataSource 생성자
  const NotificationRemoteDataSource();

  /// Serverpod Client
  pod.Client get _client => PodService.instance.client;

  /// 🧪 Mock 데이터 사용 여부 (테스트용)
  static const bool _useMockData = true;

  /// 🧪 Mock 데이터 생성
  pod.NotificationListResponseDto _generateMockNotifications({
    required int page,
    required int limit,
  }) {
    const totalCount = 50; // 총 50개의 mock 알림
    final now = DateTime.now();
    final notifications = <pod.NotificationResponseDto>[];

    // 페이지네이션 계산
    final offset = (page - 1) * limit;
    final totalPages = (totalCount / limit).ceil();
    final hasMore = page < totalPages;
    final endIndex =
        (offset + limit) > totalCount ? totalCount : offset + limit;

    // 현재 페이지에 해당하는 알림 생성
    for (var i = offset; i < endIndex; i++) {
      final notificationId = i + 1;
      final isRead = i % 3 == 0; // 3개 중 1개는 읽음 처리
      final rating = (i % 5) + 1; // 1~5 별점

      notifications.add(
        pod.NotificationResponseDto(
          id: notificationId,
          notificationType: pod.NotificationType.review_received,
          title: '사용자 $notificationId',
          body: '${'⭐' * rating} 거래 후기를 남겼습니다',
          data: {
            'type': 'review_received',
            'reviewerId': (notificationId + 100).toString(),
            'revieweeId': '1',
            'productId': '1',
            'chatRoomId': '1',
            'rating': rating.toString(),
          },
          isRead: isRead,
          readAt: isRead ? now.subtract(Duration(hours: i)) : null,
          createdAt: now.subtract(Duration(hours: i)),
        ),
      );
    }

    // 읽지 않은 알림 개수 계산
    const unreadCount = totalCount - (totalCount ~/ 3);

    return pod.NotificationListResponseDto(
      notifications: notifications,
      pagination: pod.PaginationDto(
        page: page,
        limit: limit,
        totalCount: totalCount,
        hasMore: hasMore,
      ),
      unreadCount: unreadCount,
    );
  }

  /// 알림 목록 조회 (페이지네이션)
  Future<pod.NotificationListResponseDto> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    if (_useMockData) {
      // Mock 데이터 반환
      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      ); // 네트워크 지연 시뮬레이션
      return _generateMockNotifications(page: page, limit: limit);
    }

    return _client.notification.getNotifications(
      page: page,
      limit: limit,
    );
  }

  /// 알림 읽음 처리
  Future<bool> markAsRead(int notificationId) async {
    return _client.notification.markAsRead(notificationId);
  }

  /// 알림 삭제
  Future<bool> deleteNotification(int notificationId) async {
    return _client.notification.deleteNotification(notificationId);
  }

  /// 읽지 않은 알림 개수 조회
  Future<int> getUnreadCount() async {
    return _client.notification.getUnreadCount();
  }
}
