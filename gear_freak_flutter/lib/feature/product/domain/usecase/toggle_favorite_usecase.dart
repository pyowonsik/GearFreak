import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 찜 추가/제거 UseCase
class ToggleFavoriteUseCase implements UseCase<bool, int, ProductRepository> {
  /// 찜 추가/제거 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const ToggleFavoriteUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

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
