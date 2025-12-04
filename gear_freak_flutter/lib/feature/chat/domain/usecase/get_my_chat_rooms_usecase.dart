import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';

/// 사용자가 참여한 모든 채팅방 목록 조회 UseCase
class GetMyChatRoomsUseCase
    implements UseCase<List<pod.ChatRoom>?, GetMyChatRoomsParams, ChatRepository> {
  /// GetMyChatRoomsUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const GetMyChatRoomsUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, List<pod.ChatRoom>?>> call(
    GetMyChatRoomsParams param,
  ) async {
    try {
      final result = await repository.getMyChatRooms();
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetMyChatRoomsFailure(
          '내 채팅방 목록을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 사용자가 참여한 모든 채팅방 목록 조회 파라미터
class GetMyChatRoomsParams {
  /// GetMyChatRoomsParams 생성자
  const GetMyChatRoomsParams();
}

