import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 채팅 메시지 조회 UseCase (페이지네이션)
class GetChatMessagesUseCase
    implements
        UseCase<pod.PaginatedChatMessagesResponseDto, GetChatMessagesParams,
            ChatRepository> {
  /// GetChatMessagesUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const GetChatMessagesUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, pod.PaginatedChatMessagesResponseDto>> call(
    GetChatMessagesParams param,
  ) async {
    try {
      final result = await repository.getChatMessages(
        chatRoomId: param.chatRoomId,
        page: param.page,
        limit: param.limit,
        messageType: param.messageType,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetChatMessagesFailure(
          '메시지를 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 채팅 메시지 조회 파라미터
class GetChatMessagesParams {
  /// GetChatMessagesParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [page]는 페이지 번호입니다 (1부터 시작).
  /// [limit]는 페이지당 항목 수입니다.
  /// [messageType]는 메시지 타입 필터입니다 (선택적).
  const GetChatMessagesParams({
    required this.chatRoomId,
    this.page = 1,
    this.limit = 50,
    this.messageType,
  });

  /// 채팅방 ID
  final int chatRoomId;

  /// 페이지 번호 (1부터 시작)
  final int page;

  /// 페이지당 항목 수
  final int limit;

  /// 메시지 타입 필터 (선택적)
  final pod.MessageType? messageType;
}
