import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 상품 수정 UseCase
class UpdateProductUseCase
    implements
        UseCase<pod.Product, pod.UpdateProductRequestDto, ProductRepository> {
  /// 상품 수정 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const UpdateProductUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.Product>> call(
    pod.UpdateProductRequestDto param,
  ) async {
    try {
      final result = await repository.updateProduct(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        UpdateProductFailure(
          '상품을 수정할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
