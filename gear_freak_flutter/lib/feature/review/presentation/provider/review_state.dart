import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 리뷰 상태
sealed class ReviewState {
  /// ReviewState 생성자
  const ReviewState();
}

/// 초기 상태
class ReviewInitial extends ReviewState {
  /// ReviewInitial 생성자
  const ReviewInitial();
}

/// 로딩 중
class ReviewLoading extends ReviewState {
  /// ReviewLoading 생성자
  const ReviewLoading();
}

/// 작성 성공
class ReviewSuccess extends ReviewState {
  /// ReviewSuccess 생성자
  const ReviewSuccess(this.review);

  /// 작성된 후기
  final pod.TransactionReviewResponseDto review;
}

/// 에러 상태
class ReviewError extends ReviewState {
  /// ReviewError 생성자
  const ReviewError(this.message);

  /// 에러 메시지
  final String message;
}
