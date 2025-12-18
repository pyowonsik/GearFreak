import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/failure/failure.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/domain.dart';

/// 다른 사용자의 상품 목록 조회 UseCase 파라미터
class GetProductsByUserIdParams {
  /// GetProductsByUserIdParams 생성자
  ///
  /// [userId]는 조회할 사용자의 ID입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  const GetProductsByUserIdParams({
    required this.userId,
    required this.pagination,
  });

  /// 조회할 사용자의 ID
  final int userId;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;
}

/// 다른 사용자의 상품 목록 조회 UseCase
class GetProductsByUserIdUseCase
    implements
        UseCase<pod.PaginatedProductsResponseDto, GetProductsByUserIdParams,
            ProductRepository> {
  /// 다른 사용자의 상품 목록 조회 UseCase 생성자
  ///
  /// [repository]는 상품 Repository 인스턴스입니다.
  const GetProductsByUserIdUseCase(this.repository);

  /// 상품 Repository 인스턴스
  final ProductRepository repository;

  @override
  ProductRepository get repo => repository;

  @override
  Future<Either<Failure, pod.PaginatedProductsResponseDto>> call(
    GetProductsByUserIdParams param,
  ) async {
    try {
      final result = await repository.getProductsByUserId(
        param.userId,
        param.pagination,
      );
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        GetProductsByUserIdFailure(
          '다른 사용자의 상품 목록을 불러올 수 없습니다.',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

