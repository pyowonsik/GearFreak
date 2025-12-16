import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';

/// 리뷰 원격 데이터 소스
/// Data Layer: API 호출
class ReviewRemoteDataSource {
  /// ReviewRemoteDataSource 생성자
  const ReviewRemoteDataSource();

  /// Serverpod Client
  pod.Client get _client => PodService.instance.client;

  /// 거래 후기 작성
  Future<pod.TransactionReviewResponseDto> createTransactionReview(
    pod.CreateTransactionReviewRequestDto request,
  ) async {
    try {
      return await _client.review.createTransactionReview(request);
    } catch (e) {
      throw Exception('후기 작성에 실패했습니다: $e');
    }
  }

  /// 구매자 후기 목록 조회 (페이지네이션)
  /// 판매자가 구매자에게 쓴 후기 (내가 구매자일 때 받은 후기)
  Future<pod.TransactionReviewListResponseDto> getBuyerReviews({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _client.review.getBuyerReviews(
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw Exception('구매자 후기 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 판매자 후기 목록 조회 (페이지네이션)
  /// 구매자가 판매자에게 쓴 후기 (내가 판매자일 때 받은 후기)
  Future<pod.TransactionReviewListResponseDto> getSellerReviews({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _client.review.getSellerReviews(
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw Exception('판매자 후기 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 거래 후기 삭제
  Future<bool> deleteTransactionReview(int reviewId) async {
    try {
      return await _client.review.deleteTransactionReview(reviewId);
    } catch (e) {
      throw Exception('후기 삭제에 실패했습니다: $e');
    }
  }

  /// 상품 ID로 후기 삭제 (상품 상태 변경 시 사용)
  Future<int> deleteReviewsByProductId(int productId) async {
    try {
      return await _client.review.deleteReviewsByProductId(productId);
    } catch (e) {
      throw Exception('상품 후기 삭제에 실패했습니다: $e');
    }
  }
}
