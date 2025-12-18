import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';

/// 리뷰 원격 데이터 소스
/// Data Layer: API 호출
class ReviewRemoteDataSource {
  /// ReviewRemoteDataSource 생성자
  const ReviewRemoteDataSource();

  /// Serverpod Client
  pod.Client get _client => PodService.instance.client;

  /// 🧪 Mock 데이터 사용 여부 (테스트용)
  static const bool _useMockData = false;

  /// 🧪 Mock 데이터 생성
  List<pod.TransactionReviewResponseDto> _generateMockReviews({
    required int totalCount,
    required pod.ReviewType reviewType,
  }) {
    final reviews = <pod.TransactionReviewResponseDto>[];
    final now = DateTime.now();

    for (var i = 0; i < totalCount; i++) {
      reviews.add(
        pod.TransactionReviewResponseDto(
          id: i + 1,
          productId: 1,
          chatRoomId: 1,
          reviewerId: i + 100,
          reviewerNickname: '사용자${i + 1}',
          reviewerProfileImageUrl:
              i % 3 == 0 ? 'https://picsum.photos/seed/${i + 1}/200' : null,
          revieweeId: 1,
          revieweeNickname: '나',
          rating: (i % 5) + 1, // 1~5 별점
          content: i % 3 == 0
              ? '정말 좋은 거래였습니다!'
                  ' 상품 상태도 설명과 같았고, 판매자님도 친절하셨어요. 다음에 또 거래하고 싶습니다. 추천합니다! 👍'
              : i % 3 == 1
                  ? '배송이 빠르고 상품 상태가 좋았습니다.'
                  : null,
          reviewType: reviewType,
          createdAt: now.subtract(Duration(days: i)),
        ),
      );
    }

    return reviews;
  }

  /// 거래 후기 작성 (구매자 후기: 판매자 → 구매자)
  Future<pod.TransactionReviewResponseDto> createTransactionReview(
    pod.CreateTransactionReviewRequestDto request,
  ) async {
    try {
      return await _client.review.createTransactionReview(request);
    } catch (e) {
      throw Exception('후기 작성에 실패했습니다: $e');
    }
  }

  /// 판매자 후기 작성 (구매자 → 판매자)
  Future<pod.TransactionReviewResponseDto> createSellerReview(
    pod.CreateTransactionReviewRequestDto request,
  ) async {
    try {
      return await _client.review.createSellerReview(request);
    } catch (e) {
      throw Exception('판매자 후기 작성에 실패했습니다: $e');
    }
  }

  /// 구매자 후기 목록 조회 (페이지네이션)
  /// 판매자가 구매자에게 쓴 후기 (내가 구매자일 때 받은 후기)
  Future<pod.TransactionReviewListResponseDto> getBuyerReviews({
    int page = 1,
    int limit = 10,
  }) async {
    // 🧪 Mock 데이터 사용
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      const totalMockReviews = 63; // 총 63개의 mock 데이터
      final allReviews = _generateMockReviews(
        totalCount: totalMockReviews,
        reviewType: pod.ReviewType.seller_to_buyer,
      );

      // 페이지네이션 처리
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedReviews = allReviews.sublist(
        startIndex,
        endIndex > allReviews.length ? allReviews.length : endIndex,
      );

      return pod.TransactionReviewListResponseDto(
        reviews: paginatedReviews,
        pagination: pod.PaginationDto(
          page: page,
          limit: limit,
          totalCount: totalMockReviews,
          hasMore: endIndex < allReviews.length,
        ),
      );
    }

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
    // 🧪 Mock 데이터 사용
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      const totalMockReviews = 67; // 총 67개의 mock 데이터
      final allReviews = _generateMockReviews(
        totalCount: totalMockReviews,
        reviewType: pod.ReviewType.buyer_to_seller,
      );

      // 페이지네이션 처리
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedReviews = allReviews.sublist(
        startIndex,
        endIndex > allReviews.length ? allReviews.length : endIndex,
      );

      return pod.TransactionReviewListResponseDto(
        reviews: paginatedReviews,
        pagination: pod.PaginationDto(
          page: page,
          limit: limit,
          totalCount: totalMockReviews,
          hasMore: endIndex < allReviews.length,
        ),
      );
    }

    try {
      return await _client.review.getSellerReviews(
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw Exception('판매자 후기 목록을 불러오는데 실패했습니다: $e');
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

  /// 리뷰 존재 여부 확인
  Future<bool> checkReviewExists({
    required int productId,
    required int chatRoomId,
    required pod.ReviewType reviewType,
  }) async {
    try {
      return await _client.review.checkReviewExists(
        productId,
        chatRoomId,
        reviewType,
      );
    } catch (e) {
      throw Exception('리뷰 존재 여부 확인에 실패했습니다: $e');
    }
  }

  /// 다른 사용자의 모든 후기 조회 (구매자 후기 + 판매자 후기, 평균 평점 포함)
  Future<pod.TransactionReviewListResponseDto> getAllReviewsByUserId({
    required int userId,
    int page = 1,
    int limit = 10,
  }) async {
    // 🧪 Mock 데이터 사용
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      const totalMockReviews = 50; // 총 50개의 mock 데이터
      final now = DateTime.now();

      // 구매자 후기와 판매자 후기를 섞어서 생성
      final allReviews = <pod.TransactionReviewResponseDto>[];

      for (var i = 0; i < totalMockReviews; i++) {
        final reviewType = i % 2 == 0
            ? pod.ReviewType.buyer_to_seller
            : pod.ReviewType.seller_to_buyer;

        allReviews.add(
          pod.TransactionReviewResponseDto(
            id: i + 1,
            productId: 1 + (i % 10),
            chatRoomId: 1 + (i % 10),
            reviewerId: 100 + i,
            reviewerNickname: '사용자${i + 1}',
            reviewerProfileImageUrl:
                i % 3 == 0 ? 'https://picsum.photos/seed/${i + 1}/200' : null,
            revieweeId: userId, // 조회 대상 사용자 ID
            revieweeNickname: '대상사용자',
            rating: (i % 5) + 1, // 1~5 별점
            content: i % 3 == 0
                ? '정말 좋은 거래였습니다!'
                    ' 상품 상태도 설명과 같았고, 판매자님도 친절하셨어요. 다음에 또 거래하고 싶습니다. 추천합니다! 👍'
                : i % 3 == 1
                    ? '배송이 빠르고 상품 상태가 좋았습니다.'
                    : null,
            reviewType: reviewType,
            createdAt: now.subtract(Duration(days: i)),
          ),
        );
      }

      // 날짜순으로 정렬 (최신순)
      allReviews.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate); // 내림차순 (최신이 먼저)
      });

      // 평균 평점 계산
      final totalRating = allReviews.fold<int>(
        0,
        (sum, review) => sum + review.rating,
      );
      final averageRating =
          allReviews.isNotEmpty ? totalRating / allReviews.length : null;

      // 페이지네이션 처리
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedReviews = allReviews.sublist(
        startIndex,
        endIndex > allReviews.length ? allReviews.length : endIndex,
      );

      return pod.TransactionReviewListResponseDto(
        reviews: paginatedReviews,
        pagination: pod.PaginationDto(
          page: page,
          limit: limit,
          totalCount: allReviews.length,
          hasMore: endIndex < allReviews.length,
        ),
        averageRating: averageRating,
      );
    }

    try {
      return await _client.review.getAllReviewsByUserId(
        userId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw Exception('다른 사용자의 후기 목록을 불러오는데 실패했습니다: $e');
    }
  }
}
