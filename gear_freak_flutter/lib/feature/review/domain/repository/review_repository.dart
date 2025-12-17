import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 리뷰 리포지토리 인터페이스
/// Domain Layer: Repository 계약
abstract class ReviewRepository {
  /// 거래 후기 작성 (구매자 후기: 판매자 → 구매자)
  Future<pod.TransactionReviewResponseDto> createTransactionReview(
    pod.CreateTransactionReviewRequestDto request,
  );

  /// 판매자 후기 작성 (구매자 → 판매자)
  Future<pod.TransactionReviewResponseDto> createSellerReview(
    pod.CreateTransactionReviewRequestDto request,
  );

  /// 구매자 후기 목록 조회 (페이지네이션)
  /// 구매자가 나에게 쓴 후기
  Future<pod.TransactionReviewListResponseDto> getBuyerReviews({
    int page = 1,
    int limit = 10,
  });

  /// 판매자 후기 목록 조회 (페이지네이션)
  /// 판매자가 나에게 쓴 후기
  Future<pod.TransactionReviewListResponseDto> getSellerReviews({
    int page = 1,
    int limit = 10,
  });

  /// 거래 후기 삭제
  Future<bool> deleteTransactionReview(int reviewId);

  /// 상품 ID로 후기 삭제 (상품 상태 변경 시 사용)
  Future<int> deleteReviewsByProductId(int productId);
}
