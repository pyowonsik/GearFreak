import 'package:flutter/material.dart';

/// 홈 화면 AppBar 위젯
class HomeAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  /// HomeAppBarWidget 생성자
  ///
  /// [onNotificationPressed]는 알림 버튼 클릭 콜백입니다.
  const HomeAppBarWidget({
    this.onNotificationPressed,
    super.key,
  });

  /// 알림 버튼 클릭 콜백
  final VoidCallback? onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.shopping_bag,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 8),
          const Text('운동은 장비충'),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationPressed,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

