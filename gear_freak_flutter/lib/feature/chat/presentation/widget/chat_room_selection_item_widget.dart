import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/presentation/utils/chat_room_util.dart';
import 'package:go_router/go_router.dart';

/// 채팅방 선택 화면용 아이템 위젯
/// Presentation Layer: 재사용 가능한 위젯
class ChatRoomSelectionItemWidget extends ConsumerWidget {
  /// ChatRoomSelectionItemWidget 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  /// [participants]는 참여자 목록입니다.
  const ChatRoomSelectionItemWidget({
    required this.chatRoom,
    this.participants,
    super.key,
  });

  /// 채팅방 정보
  final pod.ChatRoom chatRoom;

  /// 참여자 목록 (선택)
  final List<pod.ChatParticipantInfoDto>? participants;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상대방 닉네임 가져오기
    final otherParticipantName = ChatRoomUtil.getOtherParticipantName(
      ref,
      participants: participants,
      defaultName: chatRoom.title ?? '채팅방',
    );

    // 상대방 프로필 이미지 가져오기
    final otherParticipant = ChatRoomUtil.getOtherParticipant(
      ref,
      participants: participants,
    );
    final profileImageUrl = otherParticipant?.profileImageUrl;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF3F4F6),
            backgroundImage: profileImageUrl != null
                ? CachedNetworkImageProvider(profileImageUrl)
                : null,
            child: profileImageUrl == null
                ? Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.grey.shade500,
                  )
                : null,
          ),
          title: Text(
            otherParticipantName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF1F2937),
            ),
          ),
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
