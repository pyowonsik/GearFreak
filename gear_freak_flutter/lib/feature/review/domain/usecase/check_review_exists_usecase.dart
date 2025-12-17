import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/failure/failure.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/review/domain/failures/review_failure.dart';
import 'package:gear_freak_flutter/feature/review/domain/repository/review_repository.dart';

/// 리뷰 존재 여부 확인 UseCase 파라미터
class CheckReviewExistsParams {
  /// CheckReviewExistsParams 생성자
  const CheckReviewExistsParams({
    required this.productId,
    required this.chatRoomId,
    required this.reviewType,
  });

  /// 상품 ID
  final int productId;

  /// 채팅방 ID
  final int chatRoomId;

  /// 리뷰 타입
  final pod.ReviewType reviewType;
}

/// 리뷰 존재 여부 확인 UseCase
class CheckReviewExistsUseCase
    implements UseCase<bool, CheckReviewExistsParams, ReviewRepository> {
  /// CheckReviewExistsUseCase 생성자
  const CheckReviewExistsUseCase(this.repository);

  /// 리뷰 리포지토리
  final ReviewRepository repository;

  @override
  ReviewRepository get repo => repository;

  @override
  Future<Either<Failure, bool>> call(
    CheckReviewExistsParams param,
  ) async {
    try {
      final result = await repository.checkReviewExists(
        productId: param.productId,
        chatRoomId: param.chatRoomId,
        reviewType: param.reviewType,
      );
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        CheckReviewExistsFailure(
          '리뷰 존재 여부 확인에 실패했습니다: ${e.toString()}',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
