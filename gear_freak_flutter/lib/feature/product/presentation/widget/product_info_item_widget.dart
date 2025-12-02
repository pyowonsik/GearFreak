import 'package:flutter/material.dart';

/// 상품 정보 항목 위젯 (Row 형태)
///
/// 아이콘과 라벨을 가진 상품 정보 항목을 표시합니다.
class ProductInfoItemWidget extends StatelessWidget {
  /// ProductInfoItemWidget 생성자
  ///
  /// [icon]는 항목 아이콘입니다.
  /// [label]는 항목 라벨입니다.
  const ProductInfoItemWidget({
    required this.icon,
    required this.label,
    super.key,
  });

  /// 항목 아이콘
  final IconData icon;

  /// 항목 라벨
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
