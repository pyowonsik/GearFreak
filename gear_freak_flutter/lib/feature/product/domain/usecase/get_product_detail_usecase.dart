import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/domain/usecase/usecase.dart';
import '../domain.dart';

/// 상품 상세 조회 UseCase
class GetProductDetailUseCase
    implements UseCase<pod.Product, int, ProductRepository> {
  final ProductRepository repository;

  const GetProductDetailUseCase(this.repository);

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.Product>> call(int param) async {
    try {
      final result = await repository.getProductDetail(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetProductDetailFailure(
          '상품 상세를 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

