import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/review/domain/failures/review_failure.dart';
import 'package:gear_freak_flutter/feature/review/domain/repository/review_repository.dart';
import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 구매자 후기 목록 조회 UseCase 파라미터
class GetBuyerReviewsParams {
  /// GetBuyerReviewsParams 생성자
  const GetBuyerReviewsParams({
    this.page = 1,
    this.limit = 10,
  });

  /// 페이지 번호
  final int page;

  /// 페이지당 항목 수
  final int limit;
}

/// 구매자 후기 목록 조회 UseCase
/// 구매자가 나에게 쓴 후기
class GetBuyerReviewsUseCase
    implements
        UseCase<pod.TransactionReviewListResponseDto, GetBuyerReviewsParams,
            ReviewRepository> {
  /// GetBuyerReviewsUseCase 생성자
  const GetBuyerReviewsUseCase(this.repository);

  /// 리뷰 리포지토리
  final ReviewRepository repository;

  @override
  ReviewRepository get repo => repository;

  @override
  Future<Either<Failure, pod.TransactionReviewListResponseDto>> call(
    GetBuyerReviewsParams param,
  ) async {
    try {
      final result = await repository.getBuyerReviews(
        page: param.page,
        limit: param.limit,
      );
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        GetBuyerReviewsFailure(
          '구매자 후기 목록을 불러오는데 실패했습니다: $e',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
