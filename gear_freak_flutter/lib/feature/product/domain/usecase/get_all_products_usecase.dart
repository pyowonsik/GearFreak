import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/domain/usecase/usecase.dart';
import '../domain.dart';

/// 전체 상품 조회 UseCase
class GetAllProductsUseCase
    implements UseCase<List<pod.Product>, void, ProductRepository> {
  final ProductRepository repository;

  const GetAllProductsUseCase(this.repository);

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, List<pod.Product>>> call(void param) async {
    try {
      final result = await repository.getAllProducts();
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

