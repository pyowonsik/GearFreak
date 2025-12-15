import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/utils/chat_room_util.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/widget/product_avatar_widget.dart';
import 'package:go_router/go_router.dart';

/// 채팅방 아이템 위젯
/// Presentation Layer: 재사용 가능한 위젯
class ChatRoomItemWidget extends ConsumerWidget {
  /// ChatRoomItemWidget 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  /// [participants]는 참여자 목록입니다. (선택, 제공되면 그룹 아바타에 사용)
  /// [lastMessage]는 마지막 메시지입니다. (선택, 제공되면 subtitle에 표시)
  /// [productImageUrl]는 상품 이미지 URL입니다. (선택, 제공되면 상품 이미지 표시)
  const ChatRoomItemWidget({
    required this.chatRoom,
    this.participants,
    this.lastMessage,
    this.productImageUrl,
    super.key,
  });

  /// 채팅방 정보
  final pod.ChatRoom chatRoom;

  /// 참여자 목록 (선택)
  final List<pod.ChatParticipantInfoDto>? participants;

  /// 마지막 메시지 (선택)
  final pod.ChatMessageResponseDto? lastMessage;

  /// 상품 이미지 URL (선택)
  final String? productImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상대방 닉네임 가져오기
    final otherParticipantName = ChatRoomUtil.getOtherParticipantName(
      ref,
      participants: participants,
      defaultName: chatRoom.title ?? '채팅방',
    );

    return Column(
      children: [
        Slidable(
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.4,
            children: [
              // 알림 설정/해제 버튼
              CustomSlidableAction(
                onPressed: (context) {
                  // TODO: 알림 설정/해제 로직 구현
                  debugPrint('알림 설정/해제: ${chatRoom.id}');
                },
                backgroundColor: const Color(0xFF3B82F6),
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_off_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '알림',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // 삭제 버튼
              CustomSlidableAction(
                onPressed: (context) async {
                  // 나가기 확인 다이얼로그 표시
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('채팅방 나가기'),
                      content: const Text(
                        '채팅방을 나가시겠습니까?\n나가기 후에도 상대방이 메시지를 보내면 다시 채팅방에 입장할 수 있습니다.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            '나가기',
                            style: TextStyle(color: Color(0xFFEF4444)),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    // 나가기 실행
                    final success = await ref
                        .read(chatRoomListNotifierProvider.notifier)
                        .leaveChatRoom(chatRoom.id!);

                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('채팅방에서 나갔습니다.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('채팅방 나가기에 실패했습니다.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                backgroundColor: const Color(0xFFEF4444),
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '삭제',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: ProductAvatarWidget(
              productImageUrl: productImageUrl,
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
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (chatRoom.lastActivityAt != null)
                  Text(
                    ChatRoomUtil.formatChatRoomTime(chatRoom.lastActivityAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                if (chatRoom.unreadCount != null &&
                    chatRoom.unreadCount! > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      chatRoom.unreadCount! > 99
                          ? '99+'
                          : '${chatRoom.unreadCount}',
                      style: const TextStyle(
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
              context.push(
                '/chat/${chatRoom.productId}?chatRoomId=${chatRoom.id}',
              );
            },
          ),
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
