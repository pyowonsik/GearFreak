import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// 채팅 메시지 버블 위젯
class ChatMessageBubbleWidget extends StatelessWidget {
  /// ChatMessageBubbleWidget 생성자
  ///
  /// [text]는 메시지 텍스트입니다.
  /// [isMine]은 내 메시지인지 여부입니다.
  /// [time]은 메시지 시간입니다.
  /// [author]는 메시지 작성자 정보입니다.
  /// [showTime]은 시간을 표시할지 여부입니다. (기본값: true)
  const ChatMessageBubbleWidget({
    required this.text,
    required this.isMine,
    required this.time,
    required this.author,
    this.showTime = true,
    super.key,
  });

  /// 메시지 텍스트
  final String text;

  /// 내 메시지인지 여부
  final bool isMine;

  /// 메시지 시간
  final String time;

  /// 메시지 작성자 정보
  final types.User author;

  /// 시간을 표시할지 여부
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            // 시간이 표시될 때만 아바타 표시 (같은 시간대면 아바타도 생략)
            if (showTime)
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF3F4F6),
                backgroundImage: author.imageUrl != null
                    ? NetworkImage(author.imageUrl!)
                    : null,
                child: author.imageUrl == null
                    ? Icon(
                        Icons.person,
                        color: Colors.grey.shade500,
                        size: 16,
                      )
                    : null,
              ),
            if (showTime) const SizedBox(width: 8),
            // 아바타가 없을 때 공간 확보
            if (!showTime) const SizedBox(width: 40),
          ],
          // 내 메시지는 시간이 왼쪽에 표시
          if (isMine && showTime) ...[
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color:
                    isMine ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isMine ? Colors.white : const Color(0xFF1F2937),
                  height: 1.4,
                ),
              ),
            ),
          ),
          // 상대방 메시지는 시간이 오른쪽에 표시
          if (!isMine && showTime) ...[
            const SizedBox(width: 8),
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
