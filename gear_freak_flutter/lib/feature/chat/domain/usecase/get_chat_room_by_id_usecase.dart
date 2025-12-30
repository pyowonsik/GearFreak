import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 채팅방 정보 조회 UseCase
class GetChatRoomByIdUseCase
    implements UseCase<pod.ChatRoom?, GetChatRoomByIdParams, ChatRepository> {
  /// GetChatRoomByIdUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const GetChatRoomByIdUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, pod.ChatRoom?>> call(
    GetChatRoomByIdParams param,
  ) async {
    try {
      final result = await repository.getChatRoomById(param.chatRoomId);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetChatRoomByIdFailure(
          '채팅방 정보를 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 채팅방 정보 조회 파라미터
class GetChatRoomByIdParams {
  /// GetChatRoomByIdParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  const GetChatRoomByIdParams({
    required this.chatRoomId,
  });

  /// 채팅방 ID
  final int chatRoomId;
}
