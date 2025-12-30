import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 상품 상세 조회 UseCase
class GetProductDetailUseCase
    implements UseCase<pod.Product, int, ProductRepository> {
  /// 상품 상세 조회 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const GetProductDetailUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.Product>> call(int param) async {
    try {
      final result = await repository.getProductDetail(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetProductDetailFailure(
          '상품 상세를 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
