import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/domain/usecase/usecase.dart';
import '../domain.dart';

/// 페이지네이션된 상품 목록 조회 UseCase
class GetPaginatedProductsUseCase
    implements UseCase<pod.PaginatedProductsResponseDto, pod.PaginationDto, ProductRepository> {
  final ProductRepository repository;

  const GetPaginatedProductsUseCase(this.repository);

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.PaginatedProductsResponseDto>> call(
    pod.PaginationDto param,
  ) async {
    try {
      final result = await repository.getPaginatedProducts(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetProductsFailure(
          '상품 목록을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}


