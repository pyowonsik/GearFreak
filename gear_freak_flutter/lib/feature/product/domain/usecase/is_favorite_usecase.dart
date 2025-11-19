import 'package:dartz/dartz.dart';
import '../../../../common/domain/usecase/usecase.dart';
import '../domain.dart';

/// 찜 상태 조회 UseCase
class IsFavoriteUseCase implements UseCase<bool, int, ProductRepository> {
  final ProductRepository repository;

  const IsFavoriteUseCase(this.repository);

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, bool>> call(int param) async {
    try {
      final result = await repository.isFavorite(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        IsFavoriteFailure(
          '찜 상태를 조회할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
