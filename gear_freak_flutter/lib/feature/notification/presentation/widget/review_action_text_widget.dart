import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/notification/di/notification_providers.dart';

/// 리뷰 알림 액션 텍스트 위젯
/// 리뷰가 작성되지 않은 경우에만 "후기 남기러가기 !" 텍스트를 표시합니다.
class ReviewActionTextWidget extends ConsumerStatefulWidget {
  /// ReviewActionTextWidget 생성자
  ///
  /// [notification]는 알림 정보입니다.
  const ReviewActionTextWidget({
    required this.notification,
    super.key,
  });

  /// 알림 정보
  final pod.NotificationResponseDto notification;

  @override
  ConsumerState<ReviewActionTextWidget> createState() =>
      _ReviewActionTextWidgetState();
}

class _ReviewActionTextWidgetState
    extends ConsumerState<ReviewActionTextWidget> {
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
    final (buyerReviewExists, sellerReviewExists) = await ref
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
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        '후기 남기러가기 !',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF2563EB), // 포인트 컬러
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
