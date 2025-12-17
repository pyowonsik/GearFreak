import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/notification/data/datasource/notification_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/notification/domain/repository/notification_repository.dart';

/// 알림 리포지토리 구현
/// Data Layer: Repository 구현
class NotificationRepositoryImpl implements NotificationRepository {
  /// NotificationRepositoryImpl 생성자
  const NotificationRepositoryImpl(this.remoteDataSource);

  /// 원격 데이터 소스
  final NotificationRemoteDataSource remoteDataSource;

  @override
  Future<pod.NotificationListResponseDto> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    return remoteDataSource.getNotifications(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<bool> markAsRead(int notificationId) async {
    return remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<bool> deleteNotification(int notificationId) async {
    return remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<int> getUnreadCount() async {
    return remoteDataSource.getUnreadCount();
  }
}
