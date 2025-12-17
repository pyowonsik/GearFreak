import 'package:gear_freak_flutter/common/domain/failure/failure.dart';

/// 리뷰 관련 실패
sealed class ReviewFailure extends Failure {
  /// ReviewFailure 생성자
  const ReviewFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 구매자 목록 조회 실패
class GetBuyersByProductIdFailure extends ReviewFailure {
  /// GetBuyersByProductIdFailure 생성자
  const GetBuyersByProductIdFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 구매자 후기 목록 조회 실패
class GetBuyerReviewsFailure extends ReviewFailure {
  /// GetBuyerReviewsFailure 생성자
  const GetBuyerReviewsFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 판매자 후기 목록 조회 실패
class GetSellerReviewsFailure extends ReviewFailure {
  /// GetSellerReviewsFailure 생성자
  const GetSellerReviewsFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 거래 후기 작성 실패
class CreateTransactionReviewFailure extends ReviewFailure {
  /// CreateTransactionReviewFailure 생성자
  const CreateTransactionReviewFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 거래 후기 삭제 실패
class DeleteTransactionReviewFailure extends ReviewFailure {
  /// DeleteTransactionReviewFailure 생성자
  const DeleteTransactionReviewFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 리뷰 존재 여부 확인 실패
class CheckReviewExistsFailure extends ReviewFailure {
  /// CheckReviewExistsFailure 생성자
  const CheckReviewExistsFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}
