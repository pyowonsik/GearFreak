import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';

/// 다른 사용자의 상품 통계 조회 UseCase 파라미터
class GetProductStatsByUserIdParams {
  /// GetProductStatsByUserIdParams 생성자
  ///
  /// [userId]는 조회할 사용자의 ID입니다.
  const GetProductStatsByUserIdParams(this.userId);

  /// 조회할 사용자의 ID
  final int userId;
}

/// 다른 사용자의 상품 통계 조회 UseCase
class GetProductStatsByUserIdUseCase
    implements
        UseCase<pod.ProductStatsDto, GetProductStatsByUserIdParams,
            ProductRepository> {
  /// 다른 사용자의 상품 통계 조회 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const GetProductStatsByUserIdUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.ProductStatsDto>> call(
    GetProductStatsByUserIdParams param,
  ) async {
    try {
      final result = await repository.getProductStatsByUserId(param.userId);
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
