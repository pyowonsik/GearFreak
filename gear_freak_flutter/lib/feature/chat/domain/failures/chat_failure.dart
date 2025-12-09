import 'package:gear_freak_flutter/common/domain/failure/failure.dart';

/// 채팅 실패 추상 클래스
abstract class ChatFailure extends Failure {
  /// ChatFailure 생성자
  const ChatFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'ChatFailure: $message';
}

/// 메시지 전송 실패
class SendMessageFailure extends ChatFailure {
  /// SendMessageFailure 생성자
  const SendMessageFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'SendMessageFailure: $message';
}

/// 메시지 읽음 처리 실패
class MarkAsReadFailure extends ChatFailure {
  /// MarkAsReadFailure 생성자
  const MarkAsReadFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'MarkAsReadFailure: $message';
}

/// 채팅방 생성 또는 조회 실패
class CreateOrGetChatRoomFailure extends ChatFailure {
  /// CreateOrGetChatRoomFailure 생성자
  const CreateOrGetChatRoomFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'CreateOrGetChatRoomFailure: $message';
}

/// 채팅방 참여 실패
class JoinChatRoomFailure extends ChatFailure {
  /// JoinChatRoomFailure 생성자
  const JoinChatRoomFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'JoinChatRoomFailure: $message';
}

/// 채팅 메시지 조회 실패
class GetChatMessagesFailure extends ChatFailure {
  /// GetChatMessagesFailure 생성자
  const GetChatMessagesFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'GetChatMessagesFailure: $message';
}

/// 채팅방 정보 조회 실패
class GetChatRoomByIdFailure extends ChatFailure {
  /// GetChatRoomByIdFailure 생성자
  const GetChatRoomByIdFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'GetChatRoomByIdFailure: $message';
}

/// 채팅방 참여자 목록 조회 실패
class GetChatParticipantsFailure extends ChatFailure {
  /// GetChatParticipantsFailure 생성자
  const GetChatParticipantsFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'GetChatParticipantsFailure: $message';
}

/// 채팅 메시지 스트림 구독 실패
class SubscribeChatMessageStreamFailure extends ChatFailure {
  /// SubscribeChatMessageStreamFailure 생성자
  const SubscribeChatMessageStreamFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'SubscribeChatMessageStreamFailure: $message';
}

/// 사용자가 참여한 채팅방 목록 조회 실패
class GetUserChatRoomsByProductIdFailure extends ChatFailure {
  /// GetUserChatRoomsByProductIdFailure 생성자
  const GetUserChatRoomsByProductIdFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'GetUserChatRoomsByProductIdFailure: $message';
}

/// 내 채팅방 목록 조회 실패
class GetMyChatRoomsFailure extends ChatFailure {
  /// GetMyChatRoomsFailure 생성자
  const GetMyChatRoomsFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'GetMyChatRoomsFailure: $message';
}
