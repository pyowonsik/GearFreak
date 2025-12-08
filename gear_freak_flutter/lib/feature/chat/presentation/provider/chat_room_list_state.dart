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
  /// [pagination]는 페이지네이션 정보입니다.
  /// [participantsMap]는 채팅방별 참여자 정보입니다. (chatRoomId -> 참여자 목록)
  /// [lastMessagesMap]는 채팅방별 마지막 메시지 정보입니다. (chatRoomId -> 마지막 메시지)
  const ChatRoomListLoaded({
    required this.chatRooms,
    required this.pagination,
    this.participantsMap = const {},
    this.lastMessagesMap = const {},
  });

  /// 채팅방 목록
  final List<pod.ChatRoom> chatRooms;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 채팅방별 참여자 정보 (chatRoomId -> 참여자 목록)
  final Map<int, List<pod.ChatParticipantInfoDto>> participantsMap;

  /// 채팅방별 마지막 메시지 정보 (chatRoomId -> 마지막 메시지)
  final Map<int, pod.ChatMessageResponseDto> lastMessagesMap;

  /// ChatRoomListLoaded 복사
  ChatRoomListLoaded copyWith({
    List<pod.ChatRoom>? chatRooms,
    pod.PaginationDto? pagination,
    Map<int, List<pod.ChatParticipantInfoDto>>? participantsMap,
    Map<int, pod.ChatMessageResponseDto>? lastMessagesMap,
  }) {
    return ChatRoomListLoaded(
      chatRooms: chatRooms ?? this.chatRooms,
      pagination: pagination ?? this.pagination,
      participantsMap: participantsMap ?? this.participantsMap,
      lastMessagesMap: lastMessagesMap ?? this.lastMessagesMap,
    );
  }
}

/// 페이지네이션 추가 로딩 중 상태 (기존 데이터 유지)
class ChatRoomListLoadingMore extends ChatRoomListLoaded {
  /// ChatRoomListLoadingMore 생성자
  const ChatRoomListLoadingMore({
    required super.chatRooms,
    required super.pagination,
    super.participantsMap = const {},
    super.lastMessagesMap = const {},
  });
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
