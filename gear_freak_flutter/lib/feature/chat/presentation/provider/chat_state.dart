import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 채팅 상태
sealed class ChatState {
  /// ChatState 생성자
  const ChatState();
}

/// 초기 상태 (채팅방이 없는 상태, 카카오톡/당근마켓 방식)
class ChatInitial extends ChatState {
  /// ChatInitial 생성자
  ///
  /// [product]는 상품 정보입니다. (채팅방이 없을 때 상품 정보 표시용)
  const ChatInitial({this.product});

  /// 상품 정보
  final pod.Product? product;
}

/// 로딩 상태
class ChatLoading extends ChatState {
  /// ChatLoading 생성자
  const ChatLoading();
}

/// 로드 완료 상태
class ChatLoaded extends ChatState {
  /// ChatLoaded 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  /// [participants]는 참여자 목록입니다.
  /// [messages]는 메시지 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [isStreamConnected]는 스트림 연결 상태입니다.
  /// [product]는 상품 정보입니다.
  const ChatLoaded({
    required this.chatRoom,
    this.participants = const [],
    this.messages = const [],
    this.pagination,
    this.isStreamConnected = false,
    this.product,
  });

  /// 채팅방 정보
  final pod.ChatRoom chatRoom;

  /// 참여자 목록
  final List<pod.ChatParticipantInfoDto> participants;

  /// 메시지 목록
  final List<pod.ChatMessageResponseDto> messages;

  /// 페이지네이션 정보
  final pod.PaginatedChatMessagesResponseDto? pagination;

  /// 스트림 연결 상태
  final bool isStreamConnected;

  /// 상품 정보
  final pod.Product? product;

  /// ChatLoaded 복사
  ChatLoaded copyWith({
    pod.ChatRoom? chatRoom,
    List<pod.ChatParticipantInfoDto>? participants,
    List<pod.ChatMessageResponseDto>? messages,
    pod.PaginatedChatMessagesResponseDto? pagination,
    bool? isStreamConnected,
    pod.Product? product,
  }) {
    return ChatLoaded(
      chatRoom: chatRoom ?? this.chatRoom,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      pagination: pagination ?? this.pagination,
      isStreamConnected: isStreamConnected ?? this.isStreamConnected,
      product: product ?? this.product,
    );
  }
}

/// 메시지 로딩 중 상태
class ChatLoadingMore extends ChatLoaded {
  /// ChatLoadingMore 생성자
  const ChatLoadingMore({
    required super.chatRoom,
    super.participants,
    super.messages,
    super.pagination,
    super.isStreamConnected,
    super.product,
  });
}

/// 이미지 업로드 중 상태
class ChatImageUploading extends ChatLoaded {
  /// ChatImageUploading 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  /// [participants]는 참여자 목록입니다.
  /// [messages]는 메시지 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [isStreamConnected]는 스트림 연결 상태입니다.
  /// [product]는 상품 정보입니다.
  /// [currentFileName]은 현재 업로드 중인 파일 이름입니다.
  const ChatImageUploading({
    required super.chatRoom,
    super.participants,
    super.messages,
    super.pagination,
    super.isStreamConnected,
    super.product,
    required this.currentFileName,
  });

  /// 현재 업로드 중인 파일 이름
  final String currentFileName;
}

/// 이미지 업로드 실패 상태
class ChatImageUploadError extends ChatLoaded {
  /// ChatImageUploadError 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  /// [participants]는 참여자 목록입니다.
  /// [messages]는 메시지 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [isStreamConnected]는 스트림 연결 상태입니다.
  /// [product]는 상품 정보입니다.
  /// [error]는 에러 메시지입니다.
  const ChatImageUploadError({
    required super.chatRoom,
    super.participants,
    super.messages,
    super.pagination,
    super.isStreamConnected,
    super.product,
    required this.error,
  });

  /// 에러 메시지
  final String error;
}

/// 에러 상태
class ChatError extends ChatState {
  /// ChatError 생성자
  ///
  /// [message]는 에러 메시지입니다.
  const ChatError(this.message);

  /// 에러 메시지
  final String message;
}
