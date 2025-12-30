import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 전체 읽지 않은 채팅 개수 조회 UseCase
class GetTotalUnreadChatCountUseCase
    implements UseCase<int, void, ChatRepository> {
  /// GetTotalUnreadChatCountUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const GetTotalUnreadChatCountUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, int>> call(void param) async {
    try {
      final result = await repository.getTotalUnreadChatCount();
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetTotalUnreadChatCountFailure(
          '읽지 않은 채팅 개수를 조회할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
