import 'package:flutter/material.dart';

/// 채팅 메시지 입력 위젯
class ChatMessageInputWidget extends StatelessWidget {
  /// ChatMessageInputWidget 생성자
  ///
  /// [controller]는 텍스트 입력 컨트롤러입니다.
  /// [onSend]는 전송 버튼 클릭 콜백입니다.
  /// [onAddPressed]는 추가 버튼 클릭 콜백입니다.
  const ChatMessageInputWidget({
    required this.controller,
    required this.onSend,
    this.onAddPressed,
    super.key,
  });

  /// 텍스트 입력 컨트롤러
  final TextEditingController controller;

  /// 전송 버튼 클릭 콜백
  final VoidCallback onSend;

  /// 추가 버튼 클릭 콜백
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF6B7280),
              ),
              onPressed: onAddPressed,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
