import 'package:flutter/material.dart';

/// 정보 항목 위젯 (ListTile 형태)
///
/// 아이콘과 제목, 클릭 이벤트를 가진 정보 항목을 표시합니다.
class InfoItemWidget extends StatelessWidget {
  /// InfoItemWidget 생성자
  ///
  /// [title]는 항목 제목입니다.
  /// [icon]는 항목 아이콘입니다. (선택)
  /// [onTap]는 항목 클릭 시 호출되는 콜백입니다.
  const InfoItemWidget({
    required this.title,
    required this.onTap,
    this.icon,
    super.key,
  });

  /// 항목 제목
  final String title;

  /// 항목 아이콘
  final IconData? icon;

  /// 항목 클릭 시 호출되는 콜백
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: const Color(0xFF4B5563)) : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1F2937),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF9CA3AF),
      ),
      onTap: onTap,
    );
  }
}
