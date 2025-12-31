import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/presentation.dart';

/// 채팅 메시지 날짜 구분선 위젯
class ChatDateSeparatorWidget extends StatelessWidget {
  /// ChatDateSeparatorWidget 생성자
  ///
  /// [dateTime]는 날짜입니다.
  const ChatDateSeparatorWidget({
    required this.dateTime,
    super.key,
  });

  /// 날짜
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    final dateText = ChatUtil.formatChatMessageDateSeparator(dateTime);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
}
