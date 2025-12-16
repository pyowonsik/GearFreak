import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/common/domain/failure/failure.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/review/domain/failures/review_failure.dart';
import 'package:gear_freak_flutter/feature/review/domain/repository/review_repository.dart';

/// 거래 후기 삭제 UseCase 파라미터
class DeleteTransactionReviewParams {
  /// DeleteTransactionReviewParams 생성자
  const DeleteTransactionReviewParams({required this.reviewId});

  /// 후기 ID
  final int reviewId;
}

/// 거래 후기 삭제 UseCase
class DeleteTransactionReviewUseCase
    implements UseCase<bool, DeleteTransactionReviewParams, ReviewRepository> {
  /// DeleteTransactionReviewUseCase 생성자
  const DeleteTransactionReviewUseCase(this.repository);

  /// 리뷰 리포지토리
  final ReviewRepository repository;

  @override
  ReviewRepository get repo => repository;

  @override
  Future<Either<Failure, bool>> call(
    DeleteTransactionReviewParams param,
  ) async {
    try {
      final result = await repository.deleteTransactionReview(param.reviewId);
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        DeleteTransactionReviewFailure(
          '후기 삭제에 실패했습니다: ${e.toString()}',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
