import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 채팅방 참여 UseCase
class JoinChatRoomUseCase
    implements
        UseCase<pod.JoinChatRoomResponseDto, JoinChatRoomParams,
            ChatRepository> {
  /// JoinChatRoomUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const JoinChatRoomUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, pod.JoinChatRoomResponseDto>> call(
    JoinChatRoomParams param,
  ) async {
    try {
      final result = await repository.joinChatRoom(param.chatRoomId);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        JoinChatRoomFailure(
          '채팅방 참여에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 채팅방 참여 파라미터
class JoinChatRoomParams {
  /// JoinChatRoomParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  const JoinChatRoomParams({
    required this.chatRoomId,
  });

  /// 채팅방 ID
  final int chatRoomId;
}
