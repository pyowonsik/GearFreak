import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/failure/failure.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/review/domain/failures/review_failure.dart';
import 'package:gear_freak_flutter/feature/review/domain/repository/review_repository.dart';

/// 거래 후기 작성 UseCase 파라미터
class CreateTransactionReviewParams {
  /// CreateTransactionReviewParams 생성자
  const CreateTransactionReviewParams({
    required this.productId,
    required this.chatRoomId,
    required this.revieweeId,
    required this.rating,
    this.content,
  });

  /// 상품 ID
  final int productId;

  /// 채팅방 ID
  final int chatRoomId;

  /// 리뷰 대상자 ID
  final int revieweeId;

  /// 평점 (1~5)
  final int rating;

  /// 후기 내용
  final String? content;
}

/// 거래 후기 작성 UseCase
class CreateTransactionReviewUseCase
    implements
        UseCase<pod.TransactionReviewResponseDto, CreateTransactionReviewParams,
            ReviewRepository> {
  /// CreateTransactionReviewUseCase 생성자
  const CreateTransactionReviewUseCase(this.repository);

  /// 리뷰 리포지토리
  final ReviewRepository repository;

  @override
  ReviewRepository get repo => repository;

  @override
  Future<Either<Failure, pod.TransactionReviewResponseDto>> call(
    CreateTransactionReviewParams param,
  ) async {
    try {
      final request = pod.CreateTransactionReviewRequestDto(
        productId: param.productId,
        chatRoomId: param.chatRoomId,
        revieweeId: param.revieweeId,
        rating: param.rating,
        content: param.content,
      );

      final result = await repository.createTransactionReview(request);
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        CreateTransactionReviewFailure(
          '후기 작성에 실패했습니다: $e',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
