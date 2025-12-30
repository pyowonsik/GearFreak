import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/review/domain/failures/review_failure.dart';
import 'package:gear_freak_flutter/feature/review/domain/repository/review_repository.dart';
import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 다른 사용자의 모든 후기 조회 UseCase 파라미터
class GetAllReviewsByUserIdParams {
  /// GetAllReviewsByUserIdParams 생성자
  const GetAllReviewsByUserIdParams({
    required this.userId,
    this.page = 1,
    this.limit = 10,
  });

  /// 사용자 ID
  final int userId;

  /// 페이지 번호
  final int page;

  /// 페이지당 항목 수
  final int limit;
}

/// 다른 사용자의 모든 후기 조회 UseCase
/// 구매자 후기 + 판매자 후기 모두 조회 (평균 평점 포함)
class GetAllReviewsByUserIdUseCase
    implements
        UseCase<pod.TransactionReviewListResponseDto,
            GetAllReviewsByUserIdParams, ReviewRepository> {
  /// GetAllReviewsByUserIdUseCase 생성자
  const GetAllReviewsByUserIdUseCase(this.repository);

  /// 리뷰 리포지토리
  final ReviewRepository repository;

  @override
  ReviewRepository get repo => repository;

  @override
  Future<Either<Failure, pod.TransactionReviewListResponseDto>> call(
    GetAllReviewsByUserIdParams param,
  ) async {
    try {
      final result = await repository.getAllReviewsByUserId(
        userId: param.userId,
        page: param.page,
        limit: param.limit,
      );
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        GetBuyerReviewsFailure(
          '다른 사용자의 후기 목록을 불러오는데 실패했습니다: $e',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
