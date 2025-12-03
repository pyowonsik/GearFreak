import 'package:flutter/material.dart';

/// 프로필 통계 항목 위젯
class ProfileStatItemWidget extends StatelessWidget {
  /// ProfileStatItemWidget 생성자
  ///
  /// [label]는 통계 라벨입니다.
  /// [value]는 통계 값입니다.
  /// [onTap]는 클릭 콜백입니다.
  const ProfileStatItemWidget({
    required this.label,
    required this.value,
    this.onTap,
    super.key,
  });

  /// 통계 라벨
  final String label;

  /// 통계 값
  final String value;

  /// 클릭 콜백
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final widget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: widget,
      );
    }

    return widget;
  }
}
