import 'package:flutter/material.dart';

/// 다른 사용자 프로필 통계 아이템 위젯
class OtherUserProfileStatItemWidget extends StatelessWidget {
  /// OtherUserProfileStatItemWidget 생성자
  ///
  /// [label]는 통계 라벨입니다.
  /// [value]는 통계 값입니다.
  /// [icon]는 통계 아이콘입니다.
  /// [color]는 통계 색상입니다.
  const OtherUserProfileStatItemWidget({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  /// 통계 라벨
  final String label;

  /// 통계 값
  final String value;

  /// 통계 아이콘
  final IconData icon;

  /// 통계 색상
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
