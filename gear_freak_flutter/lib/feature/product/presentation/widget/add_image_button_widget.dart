import 'package:flutter/material.dart';

/// 이미지 추가 버튼 위젯
class AddImageButtonWidget extends StatelessWidget {
  /// AddImageButtonWidget 생성자
  ///
  /// [onTap]는 버튼 클릭 시 호출되는 콜백입니다.
  const AddImageButtonWidget({
    required this.onTap,
    super.key,
  });

  /// 버튼 클릭 시 호출되는 콜백
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 32,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 4),
            Text(
              '사진 추가',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
