import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/review/data/datasource/review_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/review/domain/repository/review_repository.dart';

/// 리뷰 리포지토리 구현
/// Data Layer: Repository 구현
class ReviewRepositoryImpl implements ReviewRepository {
  /// ReviewRepositoryImpl 생성자
  const ReviewRepositoryImpl(this.remoteDataSource);

  /// 원격 데이터 소스
  final ReviewRemoteDataSource remoteDataSource;

  @override
  Future<pod.TransactionReviewResponseDto> createTransactionReview(
    pod.CreateTransactionReviewRequestDto request,
  ) async {
    return remoteDataSource.createTransactionReview(request);
  }

  @override
  Future<pod.TransactionReviewResponseDto> createSellerReview(
    pod.CreateTransactionReviewRequestDto request,
  ) async {
    return remoteDataSource.createSellerReview(request);
  }

  @override
  Future<pod.TransactionReviewListResponseDto> getBuyerReviews({
    int page = 1,
    int limit = 10,
  }) async {
    return remoteDataSource.getBuyerReviews(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<pod.TransactionReviewListResponseDto> getSellerReviews({
    int page = 1,
    int limit = 10,
  }) async {
    return remoteDataSource.getSellerReviews(
      page: page,
      limit: limit,
    );
  }

  @override
  Future<int> deleteReviewsByProductId(int productId) async {
    return remoteDataSource.deleteReviewsByProductId(productId);
  }

  @override
  Future<bool> checkReviewExists({
    required int productId,
    required int chatRoomId,
    required pod.ReviewType reviewType,
  }) async {
    return remoteDataSource.checkReviewExists(
      productId: productId,
      chatRoomId: chatRoomId,
      reviewType: reviewType,
    );
  }
}
