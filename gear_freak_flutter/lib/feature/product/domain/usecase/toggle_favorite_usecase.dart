import 'package:dartz/dartz.dart';
import '../../../../common/domain/usecase/usecase.dart';
import '../domain.dart';

/// 찜 추가/제거 UseCase
class ToggleFavoriteUseCase
    implements UseCase<bool, int, ProductRepository> {
  final ProductRepository repository;

  const ToggleFavoriteUseCase(this.repository);

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, bool>> call(int param) async {
    try {
      final result = await repository.toggleFavorite(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        ToggleFavoriteFailure(
          '찜 상태를 변경할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

