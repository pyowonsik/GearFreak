import 'package:flutter/material.dart';

/// Gear Freak 공통 빈 상태 뷰
/// 프로젝트에서 사용하는 모든 빈 상태 표시는 이 위젯을 사용합니다.
class GbEmptyView extends StatelessWidget {
  /// GbEmptyView 생성자
  ///
  /// [message]는 빈 상태 메시지입니다.
  /// [icon]는 아이콘입니다.
  /// [iconSize]는 아이콘 크기입니다.
  /// [iconColor]는 아이콘 색상입니다.
  const GbEmptyView({
    required this.message,
    super.key,
    this.icon,
    this.iconSize = 64,
    this.iconColor,
  });

  /// 빈 상태 메시지
  final String message;

  /// 아이콘
  final IconData? icon;

  /// 아이콘 크기
  final double iconSize;

  /// 아이콘 색상
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = iconColor ?? Colors.grey.shade300;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: defaultIconColor,
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
