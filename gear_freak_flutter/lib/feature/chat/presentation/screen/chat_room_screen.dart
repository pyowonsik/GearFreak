import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/widget/widget.dart';

/// 채팅방 화면을 표시하는 위젯입니다.
///
/// 특정 채팅방의 메시지를 표시하고 새로운 메시지를 전송할 수 있습니다.
class ChatRoomScreen extends StatefulWidget {
  /// 채팅방 화면을 생성합니다.
  ///
  /// [chatId]는 채팅방을 식별하는 고유한 문자열입니다.
  const ChatRoomScreen({
    required this.chatId,
    super.key,
  });

  /// 채팅방의 고유 식별자
  final String chatId;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': '안녕하세요! 상품 아직 판매중인가요?',
      'isMine': false,
      'time': '오후 2:30',
    },
    {
      'text': '네 판매중입니다!',
      'isMine': true,
      'time': '오후 2:31',
    },
    {
      'text': '직거래 가능한가요?',
      'isMine': false,
      'time': '오후 2:32',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isMine': true,
        'time': '오후 3:24',
      });
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatRoomAppBarWidget(
        nickname: '판매자 닉네임',
      ),
      body: Column(
        children: [
          // 상품 정보 카드
          const ChatProductInfoCardWidget(
            productName: '리프팅 벨트 (사이즈 M) 거의 새것',
            price: '150,000원',
          ),
          // 채팅 메시지 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageBubbleWidget(
                  text: message['text'] as String,
                  isMine: message['isMine'] as bool,
                  time: message['time'] as String,
                );
              },
            ),
          ),
          // 메시지 입력창
          ChatMessageInputWidget(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
