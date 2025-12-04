import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 채팅방 목록 상태
sealed class ChatRoomListState {
  /// ChatRoomListState 생성자
  const ChatRoomListState();
}

/// 초기 상태
class ChatRoomListInitial extends ChatRoomListState {
  /// ChatRoomListInitial 생성자
  const ChatRoomListInitial();
}

/// 로딩 중 상태
class ChatRoomListLoading extends ChatRoomListState {
  /// ChatRoomListLoading 생성자
  const ChatRoomListLoading();
}

/// 로드 완료 상태
class ChatRoomListLoaded extends ChatRoomListState {
  /// ChatRoomListLoaded 생성자
  ///
  /// [chatRooms]는 채팅방 목록입니다.
  const ChatRoomListLoaded({
    required this.chatRooms,
  });

  /// 채팅방 목록
  final List<pod.ChatRoom> chatRooms;

  /// ChatRoomListLoaded 복사
  ChatRoomListLoaded copyWith({
    List<pod.ChatRoom>? chatRooms,
  }) {
    return ChatRoomListLoaded(
      chatRooms: chatRooms ?? this.chatRooms,
    );
  }
}

/// 에러 상태
class ChatRoomListError extends ChatRoomListState {
  /// ChatRoomListError 생성자
  ///
  /// [message]는 에러 메시지입니다.
  const ChatRoomListError(this.message);

  /// 에러 메시지
  final String message;
}
