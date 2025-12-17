import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 알림 리포지토리 인터페이스
/// Domain Layer: Repository 계약
abstract class NotificationRepository {
  /// 알림 목록 조회 (페이지네이션)
  Future<pod.NotificationListResponseDto> getNotifications({
    int page = 1,
    int limit = 10,
  });

  /// 알림 읽음 처리
  Future<bool> markAsRead(int notificationId);

  /// 알림 삭제
  Future<bool> deleteNotification(int notificationId);

  /// 읽지 않은 알림 개수 조회
  Future<int> getUnreadCount();
}
