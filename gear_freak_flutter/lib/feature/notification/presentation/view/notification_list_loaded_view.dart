import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/notification/presentation/presentation.dart';

/// 알림 목록이 로드된 상태의 View
class NotificationListLoadedView extends StatelessWidget {
  /// NotificationListLoadedView 생성자
  ///
  /// [notifications]는 표시할 알림 목록입니다.
  /// [isLoadingMore]는 더 불러오는 중인지 여부입니다.
  /// [scrollController]는 스크롤 컨트롤러입니다.
  /// [onRefresh]는 새로고침 콜백입니다.
  /// [onNotificationTap]는 알림 탭 콜백입니다.
  /// [onNotificationDelete]는 알림 삭제 콜백입니다.
  const NotificationListLoadedView({
    required this.notifications,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onNotificationTap,
    required this.onNotificationDelete,
    this.scrollController,
    super.key,
  });

  /// 알림 목록
  final List<pod.NotificationResponseDto> notifications;

  /// 더 불러오는 중인지 여부
  final bool isLoadingMore;

  /// 새로고침 콜백
  final Future<void> Function() onRefresh;

  /// 알림 탭 콜백
  final void Function(pod.NotificationResponseDto) onNotificationTap;

  /// 알림 삭제 콜백
  final void Function(int) onNotificationDelete;

  /// 스크롤 컨트롤러
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
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
