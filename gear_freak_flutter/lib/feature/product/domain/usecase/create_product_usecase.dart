import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';

/// 상품 생성 UseCase
class CreateProductUseCase
    implements
        UseCase<pod.Product, pod.CreateProductRequestDto, ProductRepository> {
  /// 상품 생성 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const CreateProductUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.Product>> call(
    pod.CreateProductRequestDto param,
  ) async {
    try {
      final result = await repository.createProduct(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        CreateProductFailure(
          '상품을 생성할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
