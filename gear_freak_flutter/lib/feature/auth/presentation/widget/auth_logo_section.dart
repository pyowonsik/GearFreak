import 'package:flutter/material.dart';

/// 인증 화면에서 사용하는 로고 섹션 컴포넌트
class AuthLogoSection extends StatelessWidget {
  /// AuthLogoSection 생성자
  ///
  /// [iconSize]는 로고 아이콘 크기입니다.
  /// [title]는 제목 텍스트입니다.
  const AuthLogoSection({
    super.key,
    this.iconSize = 80,
    this.title = '운동은 장비빨',
  });

  /// 로고 아이콘 크기
  final double iconSize;

  /// 제목 텍스트
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.shopping_bag,
          size: iconSize,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
