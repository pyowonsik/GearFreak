import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';

/// 상품 통계 조회 UseCase
class GetProductStatsUseCase
    implements UseCase<pod.ProductStatsDto, void, ProductRepository> {
  /// 상품 통계 조회 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const GetProductStatsUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.ProductStatsDto>> call(void param) async {
    try {
      final result = await repository.getProductStats();
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetProductStatsFailure(
          '상품 통계를 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
