import 'package:flutter/material.dart';

/// 채팅 메시지 버블 위젯
class ChatMessageBubbleWidget extends StatelessWidget {
  /// ChatMessageBubbleWidget 생성자
  ///
  /// [text]는 메시지 텍스트입니다.
  /// [isMine]은 내 메시지인지 여부입니다.
  /// [time]은 메시지 시간입니다.
  const ChatMessageBubbleWidget({
    required this.text,
    required this.isMine,
    required this.time,
    super.key,
  });

  /// 메시지 텍스트
  final String text;

  /// 내 메시지인지 여부
  final bool isMine;

  /// 메시지 시간
  final String time;

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
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFF3F4F6),
              child: Icon(
                Icons.person,
                color: Colors.grey.shade500,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (isMine) ...[
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
          if (!isMine) ...[
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
