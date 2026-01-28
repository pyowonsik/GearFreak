import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

/// 리뷰 목록 서비스
/// 후기 목록 조회 관련 비즈니스 로직을 처리합니다.
class ReviewListService {
  // ==================== Public Methods ====================

  /// 받은 후기 목록 조회 (페이지네이션)
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 조회할 사용자 ID
  /// [reviewType]: 조회할 후기 타입 (구매자 후기 또는 판매자 후기)
  /// [page]: 페이지 번호 (기본값: 1)
  /// [limit]: 페이지당 항목 수 (기본값: 10)
  /// Returns: 후기 목록 응답 DTO
  static Future<TransactionReviewListResponseDto> getReceivedReviews({
    required Session session,
    required int userId,
    required ReviewType reviewType,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // 1. 전체 개수 조회 (받은 후기 중 특정 타입만)
      final totalCount = await TransactionReview.db.count(
        session,
        where: (review) =>
            review.revieweeId.equals(userId) &
            review.reviewType.equals(reviewType),
      );

      // 2. 페이지네이션 계산
      final offset = (page - 1) * limit;
      final totalPages = (totalCount / limit).ceil();
      final hasMore = page < totalPages;

      // 3. 후기 목록 조회 (받은 후기 중 특정 타입만)
      final reviews = await TransactionReview.db.find(
        session,
        where: (review) =>
            review.revieweeId.equals(userId) &
            review.reviewType.equals(reviewType),
        orderBy: (review) => review.createdAt,
        orderDescending: true,
        limit: limit,
        offset: offset,
      );

      // 4. 응답 DTO 생성 (N+1 쿼리 방지: IN 쿼리로 User 일괄 조회)
      // 4-1. 모든 reviewer/reviewee ID 수집
      final reviewerIds = reviews.map((r) => r.reviewerId).toSet();
      final revieweeIds = reviews.map((r) => r.revieweeId).toSet();
      final allUserIds = {...reviewerIds, ...revieweeIds};

      // 4-2. IN 쿼리로 한 번에 User 조회
      final users = await User.db.find(
        session,
        where: (u) => u.id.inSet(allUserIds),
      );

      // 4-3. O(1) 조회를 위한 Map 생성
      final userMap = {for (var u in users) u.id!: u};

      // 4-4. DTO 생성 (Map에서 O(1) 조회)
      final reviewDtos = <TransactionReviewResponseDto>[];
      for (final review in reviews) {
        final reviewer = userMap[review.reviewerId];
        final reviewee = userMap[review.revieweeId];

        reviewDtos.add(
          TransactionReviewResponseDto(
            id: review.id!,
            productId: review.productId,
            chatRoomId: review.chatRoomId,
            reviewerId: review.reviewerId,
            reviewerNickname: reviewer?.nickname,
            reviewerProfileImageUrl: reviewer?.profileImageUrl,
            revieweeId: review.revieweeId,
            revieweeNickname: reviewee?.nickname,
            rating: review.rating,
            content: review.content,
            reviewType: review.reviewType,
            createdAt: review.createdAt,
          ),
        );
      }

      return TransactionReviewListResponseDto(
        reviews: reviewDtos,
        pagination: PaginationDto(
          page: page,
          limit: limit,
          totalCount: totalCount,
          hasMore: hasMore,
        ),
      );
    } catch (e, stackTrace) {
      session.log(
        '[ReviewListService] getReceivedReviews - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 구매자 후기 목록 조회
  ///
  /// 판매자가 구매자에게 쓴 후기 (reviewType = seller_to_buyer)
  /// 구매자 입장에서 받은 후기입니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 조회할 사용자 ID
  /// [page]: 페이지 번호 (기본값: 1)
  /// [limit]: 페이지당 항목 수 (기본값: 10)
  /// Returns: 후기 목록 응답 DTO
  static Future<TransactionReviewListResponseDto> getBuyerReviews({
    required Session session,
    required int userId,
    int page = 1,
    int limit = 10,
  }) async {
    return getReceivedReviews(
      session: session,
      userId: userId,
      reviewType: ReviewType.seller_to_buyer, // 판매자가 구매자에게 쓴 후기
      page: page,
      limit: limit,
    );
  }

  /// 판매자 후기 목록 조회
  ///
  /// 구매자가 판매자에게 쓴 후기 (reviewType = buyer_to_seller)
  /// 판매자 입장에서 받은 후기입니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 조회할 사용자 ID
  /// [page]: 페이지 번호 (기본값: 1)
  /// [limit]: 페이지당 항목 수 (기본값: 10)
  /// Returns: 후기 목록 응답 DTO
  static Future<TransactionReviewListResponseDto> getSellerReviews({
    required Session session,
    required int userId,
    int page = 1,
    int limit = 10,
  }) async {
    return getReceivedReviews(
      session: session,
      userId: userId,
      reviewType: ReviewType.buyer_to_seller, // 구매자가 판매자에게 쓴 후기
      page: page,
      limit: limit,
    );
  }

  /// 다른 사용자의 모든 후기 조회 (구매자 후기 + 판매자 후기)
  ///
  /// 평균 평점도 함께 계산하여 반환합니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 조회할 사용자 ID
  /// [page]: 페이지 번호 (기본값: 1)
  /// [limit]: 페이지당 항목 수 (기본값: 10)
  /// Returns: 후기 목록 응답 DTO (평균 평점 포함)
  static Future<TransactionReviewListResponseDto> getAllReviewsByUserId({
    required Session session,
    required int userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // 1. 전체 개수 조회 (받은 후기 모두 - 타입 무관)
      final totalCount = await TransactionReview.db.count(
        session,
        where: (review) => review.revieweeId.equals(userId),
      );

      // 2. 평균 평점 계산 (DB 집계 함수 사용으로 최적화)
      // 모든 후기를 메모리에 로드하지 않고 DB에서 직접 평균 계산
      double? averageRating;
      if (totalCount > 0) {
        final result = await session.db.unsafeQuery(
          'SELECT AVG(rating) as avg_rating FROM transaction_review WHERE "revieweeId" = $userId',
        );
        if (result.isNotEmpty && result.first.first != null) {
          final avgValue = result.first.first;
          averageRating = avgValue is num
              ? avgValue.toDouble()
              : double.tryParse(avgValue.toString());
        }
      }

      // 3. 페이지네이션 계산
      final offset = (page - 1) * limit;
      final totalPages = (totalCount / limit).ceil();
      final hasMore = page < totalPages;

      // 4. 후기 목록 조회 (타입 무관, 최신순)
      final reviews = await TransactionReview.db.find(
        session,
        where: (review) => review.revieweeId.equals(userId),
        orderBy: (review) => review.createdAt,
        orderDescending: true,
        limit: limit,
        offset: offset,
      );

      // 5. 응답 DTO 생성 (N+1 쿼리 방지: IN 쿼리로 User 일괄 조회)
      // 5-1. 모든 reviewer/reviewee ID 수집
      final reviewerIds = reviews.map((r) => r.reviewerId).toSet();
      final revieweeIds = reviews.map((r) => r.revieweeId).toSet();
      final allUserIds = {...reviewerIds, ...revieweeIds};

      // 5-2. IN 쿼리로 한 번에 User 조회
      final users = await User.db.find(
        session,
        where: (u) => u.id.inSet(allUserIds),
      );

      // 5-3. O(1) 조회를 위한 Map 생성
      final userMap = {for (var u in users) u.id!: u};

      // 5-4. DTO 생성 (Map에서 O(1) 조회)
      final reviewDtos = <TransactionReviewResponseDto>[];
      for (final review in reviews) {
        final reviewer = userMap[review.reviewerId];
        final reviewee = userMap[review.revieweeId];

        reviewDtos.add(
          TransactionReviewResponseDto(
            id: review.id!,
            productId: review.productId,
            chatRoomId: review.chatRoomId,
            reviewerId: review.reviewerId,
            reviewerNickname: reviewer?.nickname,
            reviewerProfileImageUrl: reviewer?.profileImageUrl,
            revieweeId: review.revieweeId,
            revieweeNickname: reviewee?.nickname,
            rating: review.rating,
            content: review.content,
            reviewType: review.reviewType,
            createdAt: review.createdAt,
          ),
        );
      }

      return TransactionReviewListResponseDto(
        reviews: reviewDtos,
        pagination: PaginationDto(
          page: page,
          limit: limit,
          totalCount: totalCount,
          hasMore: hasMore,
        ),
        averageRating: averageRating,
      );
    } catch (e, stackTrace) {
      session.log(
        '[ReviewListService] getAllReviewsByUserId - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }
}

