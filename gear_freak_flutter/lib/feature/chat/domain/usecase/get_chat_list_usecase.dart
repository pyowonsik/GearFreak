import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';

/// 채팅 목록 조회 UseCase
/// Domain Layer: 단일 책임 비즈니스 로직
class GetChatListUseCase
    implements UseCase<List<ChatMessage>, void, ChatRepository> {
  /// 채팅 목록 조회 UseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const GetChatListUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

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
