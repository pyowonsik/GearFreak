import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 조회수 증가 UseCase
class IncrementViewCountUseCase
    implements UseCase<bool, int, ProductRepository> {
  /// 조회수 증가 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const IncrementViewCountUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, bool>> call(int param) async {
    try {
      final result = await repository.incrementViewCount(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        IncrementViewCountFailure(
          '조회수를 증가할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
