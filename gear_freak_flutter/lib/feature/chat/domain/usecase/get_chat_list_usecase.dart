import 'package:dartz/dartz.dart';
import '../../../../common/domain/usecase/usecase.dart';
import '../domain.dart';

/// 채팅 목록 조회 UseCase
/// Domain Layer: 단일 책임 비즈니스 로직
class GetChatListUseCase
    implements UseCase<List<ChatMessage>, void, ChatRepository> {
  final ChatRepository repository;

  const GetChatListUseCase(this.repository);

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, List<ChatMessage>>> call(void param) async {
    try {
      final result = await repository.getChatList();
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetChatListFailure(
          '채팅 목록을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
