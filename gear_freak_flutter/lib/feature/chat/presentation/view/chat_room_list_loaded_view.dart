import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/presentation/widget/widget.dart';

/// 채팅방 목록이 로드된 상태의 View
class ChatRoomListLoadedView extends StatelessWidget {
  /// ChatRoomListLoadedView 생성자
  ///
  /// [chatRoomList]는 표시할 채팅방 목록입니다.
  const ChatRoomListLoadedView({
    required this.chatRoomList,
    super.key,
  });

  /// 채팅방 목록
  final List<pod.ChatRoom> chatRoomList;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: 채팅방 목록 새로고침 로직 추가
      },
      child: ListView.builder(
        itemCount: chatRoomList.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRoomList[index];
          return ChatRoomItemWidget(chatRoom: chatRoom);
        },
      ),
    );
  }
}
