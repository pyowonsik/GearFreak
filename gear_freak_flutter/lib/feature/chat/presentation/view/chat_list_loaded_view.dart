import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/feature/chat/domain/entity/chat_message.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/widget/widget.dart';

/// 채팅 목록이 로드된 상태의 View
class ChatListLoadedView extends StatelessWidget {
  /// ChatListLoadedView 생성자
  ///
  /// [chatList]는 표시할 채팅 목록입니다.
  const ChatListLoadedView({
    required this.chatList,
    super.key,
  });

  /// 채팅 목록
  final List<ChatMessage> chatList;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: 채팅방 목록 새로고침 로직 추가
      },
      child: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return ChatItemWidget(chat: chat);
        },
      ),
    );
  }
}
