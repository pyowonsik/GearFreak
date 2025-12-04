import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/utils/format_utils.dart';

/// 채팅방 선택 모달용 채팅방 아이템 위젯
/// Presentation Layer: 재사용 가능한 위젯
class ChatRoomSelectionItemWidget extends StatelessWidget {
  /// ChatRoomSelectionItemWidget 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  /// [onTap]는 탭 콜백입니다.
  const ChatRoomSelectionItemWidget({
    required this.chatRoom,
    required this.onTap,
    super.key,
  });

  /// 채팅방 정보
  final pod.ChatRoom chatRoom;

  /// 탭 콜백
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = chatRoom.lastActivityAt != null
        ? formatChatTime(chatRoom.lastActivityAt!)
        : '';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          children: [
            // 상품 이미지
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag,
                size: 24,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 16),
            // 채팅 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.title ?? '채팅방',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '참여자 ${chatRoom.participantCount}명',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // TODO: 읽지 않은 메시지 개수 표시 (추후 구현)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
