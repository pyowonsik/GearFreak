import '../../../../common/domain/failure/failure.dart';

/// 채팅 실패 추상 클래스
abstract class ChatFailure extends Failure {
  /// ChatFailure 생성자
  const ChatFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'ChatFailure: $message';
}

/// 채팅 목록 조회 실패
class GetChatListFailure extends ChatFailure {
  /// GetChatListFailure 생성자
  const GetChatListFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'GetChatListFailure: $message';
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
