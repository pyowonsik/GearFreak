import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';

/// 상품 상단으로 올리기 UseCase
class BumpProductUseCase
    implements UseCase<pod.Product, int, ProductRepository> {
  /// 상품 상단으로 올리기 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const BumpProductUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.Product>> call(int productId) async {
    try {
      final product = await repository.bumpProduct(productId);
      return Right(product);
    } on Exception catch (e) {
      return Left(
        BumpProductFailure(
          '상품을 상단으로 올릴 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
