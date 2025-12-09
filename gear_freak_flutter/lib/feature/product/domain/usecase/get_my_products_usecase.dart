import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';

/// 내가 등록한 상품 목록 조회 UseCase
class GetMyProductsUseCase
    implements
        UseCase<pod.PaginatedProductsResponseDto, pod.PaginationDto,
            ProductRepository> {
  /// 내가 등록한 상품 목록 조회 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const GetMyProductsUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.PaginatedProductsResponseDto>> call(
    pod.PaginationDto param,
  ) async {
    try {
      final result = await repository.getMyProducts(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetMyProductsFailure(
          '내 상품 목록을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
