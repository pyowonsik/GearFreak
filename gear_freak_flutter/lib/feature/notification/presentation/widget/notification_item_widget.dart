import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/notification/di/notification_providers.dart';

/// 알림 아이템 위젯
class NotificationItemWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                      .withOpacity(0.1),
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
                      _ReviewActionText(
                        notification: notification,
                        ref: ref,
                      ),
                    const SizedBox(height: 8),
                    // 시간
                    if (notification.createdAt != null)
                      Text(
                        _formatDateTime(notification.createdAt!),
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

  /// 날짜/시간 포맷팅
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

/// 리뷰 알림 액션 텍스트 위젯
/// 리뷰가 작성되지 않은 경우에만 "후기 남기러가기 !" 텍스트를 표시합니다.
class _ReviewActionText extends ConsumerStatefulWidget {
  const _ReviewActionText({
    required this.notification,
    required this.ref,
  });

  final pod.NotificationResponseDto notification;
  final WidgetRef ref;

  @override
  ConsumerState<_ReviewActionText> createState() => _ReviewActionTextState();
}

class _ReviewActionTextState extends ConsumerState<_ReviewActionText> {
  bool _isChecking = true;
  bool _reviewExists = false;

  @override
  void initState() {
    super.initState();
    _checkReviewExists();
  }

  Future<void> _checkReviewExists() async {
    final data = widget.notification.data;
    if (data == null || data.isEmpty) {
      setState(() {
        _isChecking = false;
      });
      return;
    }

    final productId = int.tryParse(data['productId']?.toString() ?? '');
    final chatRoomId = int.tryParse(data['chatRoomId']?.toString() ?? '');

    if (productId == null || chatRoomId == null) {
      setState(() {
        _isChecking = false;
      });
      return;
    }

    // 리뷰 존재 여부 확인 (양쪽 모두 확인)
    final (buyerReviewExists, sellerReviewExists) = await widget.ref
        .read(notificationListNotifierProvider.notifier)
        .checkReviewExists(
          productId: productId,
          chatRoomId: chatRoomId,
        );

    if (!mounted) return;

    // 판매자 리뷰가 있으면 → 구매자가 알림 받음 → 구매자는 판매자에게 리뷰 작성해야 함
    // 구매자 리뷰가 있으면 → 판매자가 알림 받음 → 판매자는 구매자에게 리뷰 작성해야 함
    // 양쪽 모두 있으면 → 리뷰 작성 불필요
    // 양쪽 모두 없으면 → 리뷰 작성 필요

    final reviewExists = buyerReviewExists || sellerReviewExists;

    setState(() {
      _isChecking = false;
      _reviewExists = reviewExists;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const SizedBox.shrink();
    }

    // 리뷰가 이미 작성되어 있으면 텍스트 표시 안 함
    if (_reviewExists) {
      return const SizedBox.shrink();
    }

    // 리뷰가 작성되지 않았으면 "후기 남기러가기 !" 텍스트 표시
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '후기 남기러가기 !',
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF2563EB), // 포인트 컬러
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
