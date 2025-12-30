import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 상품 삭제 UseCase
class DeleteProductUseCase implements UseCase<void, int, ProductRepository> {
  /// 상품 삭제 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const DeleteProductUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, void>> call(int productId) async {
    try {
      await repository.deleteProduct(productId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(
        DeleteProductFailure(
          '상품을 삭제할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
