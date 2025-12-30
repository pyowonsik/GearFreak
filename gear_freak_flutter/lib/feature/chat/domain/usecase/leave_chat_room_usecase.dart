import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 채팅방 나가기 UseCase
class LeaveChatRoomUseCase
    implements
        UseCase<pod.LeaveChatRoomResponseDto, LeaveChatRoomParams,
            ChatRepository> {
  /// LeaveChatRoomUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const LeaveChatRoomUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, pod.LeaveChatRoomResponseDto>> call(
    LeaveChatRoomParams param,
  ) async {
    try {
      final result = await repository.leaveChatRoom(param.chatRoomId);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        LeaveChatRoomFailure(
          '채팅방 나가기에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 채팅방 나가기 파라미터
class LeaveChatRoomParams {
  /// LeaveChatRoomParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  const LeaveChatRoomParams({
    required this.chatRoomId,
  });

  /// 채팅방 ID
  final int chatRoomId;
}

/// 채팅방 나가기 실패
class LeaveChatRoomFailure extends Failure {
  /// LeaveChatRoomFailure 생성자
  const LeaveChatRoomFailure(
    super.message, {
    super.exception,
  });
}
