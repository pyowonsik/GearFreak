import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 내가 관심목록한 상품 목록 조회 UseCase
class GetMyFavoriteProductsUseCase
    implements
        UseCase<pod.PaginatedProductsResponseDto, pod.PaginationDto,
            ProductRepository> {
  /// 내가 관심목록한 상품 목록 조회 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const GetMyFavoriteProductsUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.PaginatedProductsResponseDto>> call(
    pod.PaginationDto param,
  ) async {
    try {
      final result = await repository.getMyFavoriteProducts(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetMyFavoriteProductsFailure(
          '찜 목록을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
