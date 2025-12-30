import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 채팅방 참여자 목록 조회 UseCase
class GetChatParticipantsUseCase
    implements
        UseCase<List<pod.ChatParticipantInfoDto>, GetChatParticipantsParams,
            ChatRepository> {
  /// GetChatParticipantsUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const GetChatParticipantsUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, List<pod.ChatParticipantInfoDto>>> call(
    GetChatParticipantsParams param,
  ) async {
    try {
      final result = await repository.getChatParticipants(param.chatRoomId);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetChatParticipantsFailure(
          '참여자 목록을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 채팅방 참여자 목록 조회 파라미터
class GetChatParticipantsParams {
  /// GetChatParticipantsParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  const GetChatParticipantsParams({
    required this.chatRoomId,
  });

  /// 채팅방 ID
  final int chatRoomId;
}
