import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 상품 상태 변경 UseCase
class UpdateProductStatusUseCase
    implements
        UseCase<pod.Product, pod.UpdateProductStatusRequestDto,
            ProductRepository> {
  /// 상품 상태 변경 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const UpdateProductStatusUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.Product>> call(
    pod.UpdateProductStatusRequestDto param,
  ) async {
    try {
      final result = await repository.updateProductStatus(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        UpdateProductStatusFailure(
          '상품 상태를 변경할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
