import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/common/utils/format_utils.dart';
import 'package:gear_freak_flutter/feature/chat/domain/entity/chat_message.dart';
import 'package:go_router/go_router.dart';

/// 채팅 아이템 위젯
/// Presentation Layer: 재사용 가능한 위젯
class ChatItemWidget extends StatelessWidget {
  /// ChatItemWidget 생성자
  ///
  /// [chat]는 채팅 메시지 엔티티입니다.
  const ChatItemWidget({
    required this.chat,
    super.key,
  });

  /// 채팅 메시지 엔티티
  final ChatMessage chat;

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
        chat.senderName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        chat.content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF6B7280),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatChatTime(chat.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
            ),
          ),
          if (chat.isUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'N',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        context.push('/chat/${chat.id}');
      },
    );
  }
}
