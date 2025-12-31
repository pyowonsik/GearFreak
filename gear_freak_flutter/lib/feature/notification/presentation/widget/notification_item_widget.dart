import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/core/util/format_utils.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/presentation.dart';

/// 알림 아이템 위젯
class NotificationItemWidget extends StatelessWidget {
  /// NotificationItemWidget 생성자
  ///
  /// [notification]는 알림 정보입니다.
  /// [onTap]는 알림 탭 이벤트입니다.
  /// [onDelete]는 알림 삭제 이벤트입니다.
  const NotificationItemWidget({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  /// 알림 정보
  final pod.NotificationResponseDto notification;

  /// 알림 탭 이벤트
  final VoidCallback onTap;

  /// 알림 삭제 이벤트
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: '삭제',
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: notification.isRead
              ? Colors.white
              : const Color(0xFFF0F9FF), // 읽지 않은 알림은 연한 파란색 배경
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 알림 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.notificationType)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.notificationType),
                  color: _getNotificationColor(notification.notificationType),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // 알림 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 본문
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 리뷰 알림인 경우 "후기 남기러가기 !" 텍스트 표시 (리뷰가 작성되지 않은 경우만)
                    if (notification.notificationType ==
                        pod.NotificationType.review_received)
                      ReviewActionTextWidget(
                        notification: notification,
                      ),
                    const SizedBox(height: 8),
                    // 시간
                    if (notification.createdAt != null)
                      Text(
                        formatRelativeTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                  ],
                ),
              ),
              // 읽지 않은 알림 표시
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 알림 타입별 아이콘
  IconData _getNotificationIcon(pod.NotificationType type) {
    return switch (type) {
      pod.NotificationType.review_received => Icons.message_outlined,
    };
  }

  /// 알림 타입별 색상
  Color _getNotificationColor(pod.NotificationType type) {
    return switch (type) {
      pod.NotificationType.review_received => const Color(0xFFFFB800),
    };
  }
}
