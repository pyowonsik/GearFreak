import 'package:flutter/material.dart';

/// 채팅 AppBar 위젯
class ChatAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  /// ChatAppBarWidget 생성자
  ///
  /// [nickname]는 상대방 닉네임입니다.
  /// [onMorePressed]는 더보기 버튼 클릭 콜백입니다.
  const ChatAppBarWidget({
    required this.nickname,
    this.onMorePressed,
    super.key,
  });

  /// 상대방 닉네임
  final String nickname;

  /// 더보기 버튼 클릭 콜백
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF3F4F6),
            child: Icon(
              Icons.person,
              color: Colors.grey.shade500,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            nickname,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: onMorePressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

