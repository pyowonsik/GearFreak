import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/presentation/utils/chat_util.dart';
import 'package:go_router/go_router.dart';

/// 채팅방 아이템 위젯
/// Presentation Layer: 재사용 가능한 위젯
class ChatRoomItemWidget extends ConsumerWidget {
  /// ChatRoomItemWidget 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  /// [participants]는 참여자 목록입니다. (선택, 제공되면 그룹 아바타에 사용)
  /// [lastMessage]는 마지막 메시지입니다. (선택, 제공되면 subtitle에 표시)
  const ChatRoomItemWidget({
    required this.chatRoom,
    this.participants,
    this.lastMessage,
    super.key,
  });

  /// 채팅방 정보
  final pod.ChatRoom chatRoom;

  /// 참여자 목록 (선택)
  final List<pod.ChatParticipantInfoDto>? participants;

  /// 마지막 메시지 (선택)
  final pod.ChatMessageResponseDto? lastMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상대방 닉네임 가져오기
    final otherParticipantName = ChatUtil.getOtherParticipantName(
      ref,
      participants: participants,
      defaultName: chatRoom.title ?? '채팅방',
    );

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: ChatUtil.buildChatRoomAvatar(
            participants: participants,
            useCircleAvatar: true,
          ),
          title: Text(
            otherParticipantName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            lastMessage?.content ?? '채팅내용이 없습니다.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          trailing: chatRoom.lastActivityAt != null
              ? Text(
                  ChatUtil.formatChatRoomTime(chatRoom.lastActivityAt!),
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
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE5E7EB),
        ),
      ],
    );
  }
}
