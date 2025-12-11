import 'package:flutter/material.dart';

/// 채팅 텍스트 메시지 위젯
class ChatTextMessageWidget extends StatelessWidget {
  /// ChatTextMessageWidget 생성자
  ///
  /// [text]는 메시지 텍스트입니다.
  /// [isMine]은 내 메시지인지 여부입니다.
  const ChatTextMessageWidget({
    required this.text,
    required this.isMine,
    super.key,
  });

  /// 메시지 텍스트
  final String text;

  /// 내 메시지인지 여부
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isMine ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
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
    );
  }
}
