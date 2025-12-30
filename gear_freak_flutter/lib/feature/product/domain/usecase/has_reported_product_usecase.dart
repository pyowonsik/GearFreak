import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 상품 신고 여부 조회 UseCase
class HasReportedProductUseCase
    implements UseCase<bool, int, ProductRepository> {
  /// 상품 신고 여부 조회 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const HasReportedProductUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, bool>> call(int param) async {
    try {
      final result = await repository.hasReportedProduct(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        HasReportedProductFailure(
          '신고 여부를 조회할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
