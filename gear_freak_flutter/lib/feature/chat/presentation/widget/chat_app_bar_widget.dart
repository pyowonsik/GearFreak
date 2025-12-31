import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/presentation.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';

/// 채팅 화면 AppBar 위젯
class ChatAppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  /// ChatAppBarWidget 생성자
  ///
  /// [state]는 채팅 상태입니다.
  /// [currentUserId]는 현재 사용자 ID입니다.
  const ChatAppBarWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  /// 채팅 상태
  final ChatState state;

  /// 현재 사용자 ID
  final int? currentUserId;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state) {
      ChatLoaded(:final participants) ||
      ChatLoadingMore(:final participants) =>
        GbAppBar(
          title: Text(
            ChatRoomUtil.getOtherParticipantName(
              ref,
              participants: participants,
              defaultName: '사용자',
            ),
          ),
          actions: const [
            // IconButton(
            //   icon: const Icon(Icons.more_vert),
            //   onPressed: () {
            //   },
            // ),
          ],
        ),
      _ => const GbAppBar(
          title: Text('채팅'),
        ),
    };
  }
}
