import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/common/domain/failure/failure.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/review/domain/failures/review_failure.dart';
import 'package:gear_freak_flutter/feature/review/domain/repository/review_repository.dart';

/// 상품 ID로 후기 삭제 UseCase 파라미터
class DeleteReviewsByProductIdParams {
  /// DeleteReviewsByProductIdParams 생성자
  const DeleteReviewsByProductIdParams({required this.productId});

  /// 상품 ID
  final int productId;
}

/// 상품 ID로 후기 삭제 UseCase
class DeleteReviewsByProductIdUseCase
    implements UseCase<int, DeleteReviewsByProductIdParams, ReviewRepository> {
  /// DeleteReviewsByProductIdUseCase 생성자
  const DeleteReviewsByProductIdUseCase(this.repository);

  /// 리뷰 리포지토리
  final ReviewRepository repository;

  @override
  ReviewRepository get repo => repository;

  @override
  Future<Either<Failure, int>> call(
    DeleteReviewsByProductIdParams param,
  ) async {
    try {
      final deletedCount =
          await repository.deleteReviewsByProductId(param.productId);
      return Right(deletedCount);
    } on Exception catch (e, stackTrace) {
      return Left(
        DeleteTransactionReviewFailure(
          '상품 후기 삭제에 실패했습니다: $e',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
