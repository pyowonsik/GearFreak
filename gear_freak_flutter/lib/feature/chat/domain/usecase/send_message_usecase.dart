import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';

/// 메시지 전송 UseCase
class SendMessageUseCase
    implements
        UseCase<pod.ChatMessageResponseDto, SendMessageParams, ChatRepository> {
  /// SendMessageUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const SendMessageUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, pod.ChatMessageResponseDto>> call(
    SendMessageParams param,
  ) async {
    try {
      final result = await repository.sendMessage(
        chatRoomId: param.chatRoomId,
        productId: param.productId,
        targetUserId: param.targetUserId,
        content: param.content,
        messageType: param.messageType,
        attachmentUrl: param.attachmentUrl,
        attachmentName: param.attachmentName,
        attachmentSize: param.attachmentSize,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(
        SendMessageFailure(
          '메시지 전송에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 메시지 전송 파라미터
class SendMessageParams {
  /// SendMessageParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다. (채팅방이 없을 경우 null)
  /// [productId]는 상품 ID입니다. (채팅방이 없을 경우 필수)
  /// [targetUserId]는 상대방 사용자 ID입니다. (채팅방이 없을 경우 필수)
  /// [content]는 메시지 내용입니다.
  /// [messageType]는 메시지 타입입니다.
  /// [attachmentUrl]는 첨부파일 URL입니다 (선택적).
  /// [attachmentName]는 첨부파일 이름입니다 (선택적).
  /// [attachmentSize]는 첨부파일 크기입니다 (선택적).
  const SendMessageParams({
    required this.content,
    required this.messageType,
    this.chatRoomId,
    this.productId,
    this.targetUserId,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
  });

  /// 채팅방 ID (채팅방이 없을 경우 null)
  final int? chatRoomId;

  /// 상품 ID (채팅방이 없을 경우 필수)
  final int? productId;

  /// 상대방 사용자 ID (채팅방이 없을 경우 필수)
  final int? targetUserId;

  /// 메시지 내용
  final String content;

  /// 메시지 타입
  final pod.MessageType messageType;

  /// 첨부파일 URL (선택적)
  final String? attachmentUrl;

  /// 첨부파일 이름 (선택적)
  final String? attachmentName;

  /// 첨부파일 크기 (선택적)
  final int? attachmentSize;
}
