import 'package:gear_freak_flutter/common/domain/failure/failure.dart';

/// 리뷰 관련 실패
class ReviewFailure extends Failure {
  /// ReviewFailure 생성자
  const ReviewFailure(
    super.message, {
    super.exception,
  });
}

/// 구매자 목록 조회 실패
class GetBuyersByProductIdFailure extends ReviewFailure {
  /// GetBuyersByProductIdFailure 생성자
  const GetBuyersByProductIdFailure(
    super.message, {
    super.exception,
  });
}
