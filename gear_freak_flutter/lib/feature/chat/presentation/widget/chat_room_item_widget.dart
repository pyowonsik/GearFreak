import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:go_router/go_router.dart';

/// 채팅방 아이템 위젯
/// Presentation Layer: 재사용 가능한 위젯
class ChatRoomItemWidget extends StatelessWidget {
  /// ChatRoomItemWidget 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  const ChatRoomItemWidget({
    required this.chatRoom,
    super.key,
  });

  /// 채팅방 정보
  final pod.ChatRoom chatRoom;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFFF3F4F6),
        child: Icon(
          Icons.person,
          color: Colors.grey.shade500,
        ),
      ),
      title: Text(
        chatRoom.title ?? '채팅방',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        '참여자 ${chatRoom.participantCount}명',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF6B7280),
        ),
      ),
      trailing: chatRoom.lastActivityAt != null
          ? Text(
              _formatTime(chatRoom.lastActivityAt!),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            )
          : null,
      onTap: () {
        context.push(
          '/chat/${chatRoom.productId}?chatRoomId=${chatRoom.id}',
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
