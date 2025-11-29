import 'package:flutter/material.dart';

/// 프로필 메뉴 아이템 위젯
class ProfileMenuItemWidget extends StatelessWidget {
  /// ProfileMenuItemWidget 생성자
  ///
  /// [icon]는 메뉴 아이콘입니다.
  /// [title]는 메뉴 제목입니다.
  /// [onTap]는 메뉴 클릭 콜백입니다.
  const ProfileMenuItemWidget({
    required this.icon,
    required this.title,
    this.onTap,
    super.key,
  });

  /// 메뉴 아이콘
  final IconData icon;

  /// 메뉴 제목
  final String title;

  /// 메뉴 클릭 콜백
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4B5563)),
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
