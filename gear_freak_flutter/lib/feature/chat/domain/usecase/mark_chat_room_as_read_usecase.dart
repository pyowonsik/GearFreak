import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';

/// 채팅방 읽음 처리 UseCase
class MarkChatRoomAsReadUseCase
    implements UseCase<void, MarkChatRoomAsReadParams, ChatRepository> {
  /// MarkChatRoomAsReadUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const MarkChatRoomAsReadUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, void>> call(
    MarkChatRoomAsReadParams param,
  ) async {
    try {
      await repository.markChatRoomAsRead(param.chatRoomId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(
        MarkChatRoomAsReadFailure(
          '채팅방 읽음 처리에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 채팅방 읽음 처리 파라미터
class MarkChatRoomAsReadParams {
  /// MarkChatRoomAsReadParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  const MarkChatRoomAsReadParams({
    required this.chatRoomId,
  });

  /// 채팅방 ID
  final int chatRoomId;
}

/// 채팅방 읽음 처리 실패
class MarkChatRoomAsReadFailure extends Failure {
  /// MarkChatRoomAsReadFailure 생성자
  const MarkChatRoomAsReadFailure(
    super.message, {
    super.exception,
  });
}
