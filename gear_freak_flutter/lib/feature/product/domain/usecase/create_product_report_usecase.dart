import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';

/// 상품 신고하기 UseCase
class CreateProductReportUseCase
    implements
        UseCase<pod.ProductReport, pod.CreateProductReportRequestDto,
            ProductRepository> {
  /// 상품 신고하기 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const CreateProductReportUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.ProductReport>> call(
    pod.CreateProductReportRequestDto param,
  ) async {
    try {
      final result = await repository.createProductReport(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        CreateProductReportFailure(
          '상품 신고에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}
