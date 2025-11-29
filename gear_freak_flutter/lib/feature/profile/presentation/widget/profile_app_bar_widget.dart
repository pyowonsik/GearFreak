import 'package:flutter/material.dart';

/// 프로필 화면 AppBar 위젯
class ProfileAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  /// ProfileAppBarWidget 생성자
  ///
  /// [onSettingsPressed]는 설정 버튼 클릭 콜백입니다.
  const ProfileAppBarWidget({
    this.onSettingsPressed,
    super.key,
  });

  /// 설정 버튼 클릭 콜백
  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('내 정보'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

