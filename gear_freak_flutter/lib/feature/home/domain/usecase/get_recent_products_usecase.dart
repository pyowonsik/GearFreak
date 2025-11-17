import 'package:dartz/dartz.dart';
import '../../../../common/domain/usecase/usecase.dart';
import '../domain.dart';

/// 최근 등록 상품 조회 UseCase
class GetRecentProductsUseCase
    implements UseCase<List<Product>, void, HomeRepository> {
  final HomeRepository repository;

  const GetRecentProductsUseCase(this.repository);

  @override
  HomeRepository get repo => repository;

  @override
  Future<Either<Failure, List<Product>>> call(void param) async {
    try {
      final result = await repository.getRecentProducts();
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
