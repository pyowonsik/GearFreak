import 'dart:developer' as developer;

import 'package:gear_freak_server/src/common/fcm/service/fcm_service.dart';
import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 리뷰 서비스
class ReviewService {
  /// 거래 후기 작성
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [reviewerId]는 리뷰 작성자 ID입니다.
  /// [request]는 후기 작성 요청 정보입니다.
  /// 반환: 생성된 후기 응답 DTO
  static Future<TransactionReviewResponseDto> createTransactionReview({
    required Session session,
    required int reviewerId,
    required CreateTransactionReviewRequestDto request,
  }) async {
    try {
      // 1. 평점 검증 (1~5)
      if (request.rating < 1 || request.rating > 5) {
        throw Exception('평점은 1~5 사이의 값이어야 합니다.');
      }

      // 2. 후기 내용 길이 검증 (최대 500자)
      if (request.content != null && request.content!.length > 500) {
        throw Exception('후기 내용은 최대 500자까지 입력 가능합니다.');
      }

      // 3. reviewType 결정 (기본값: seller_to_buyer, 향후 request에 포함될 수 있음)
      // 현재는 항상 seller_to_buyer로 설정 (구매자→판매자는 별도 엔드포인트 사용)
      final reviewType = ReviewType.seller_to_buyer;

      // 4. 중복 후기 확인
      final existingReview = await TransactionReview.db.findFirstRow(
        session,
        where: (review) =>
            review.productId.equals(request.productId) &
            review.chatRoomId.equals(request.chatRoomId) &
            review.reviewerId.equals(reviewerId) &
            review.reviewType.equals(reviewType),
      );

      if (existingReview != null) {
        throw Exception('이미 작성한 후기가 있습니다.');
      }

      // 5. 후기 생성
      final now = DateTime.now().toUtc();
      final review = TransactionReview(
        productId: request.productId,
        chatRoomId: request.chatRoomId,
        reviewerId: reviewerId,
        revieweeId: request.revieweeId,
        rating: request.rating,
        content: request.content,
        reviewType: reviewType,
        createdAt: now,
        updatedAt: now,
      );

      final createdReview = await TransactionReview.db.insertRow(
        session,
        review,
      );

      session.log(
        '✅ 거래 후기 작성 완료: reviewId=${createdReview.id}, '
        'reviewerId=$reviewerId, revieweeId=${request.revieweeId}',
        level: LogLevel.info,
      );

      // 5. 사용자 정보 조회
      final reviewer = await User.db.findById(session, reviewerId);
      final reviewee = await User.db.findById(session, request.revieweeId);

      // 6. 📱 FCM 알림 전송 (비동기, 실패해도 후기 작성은 성공)
      await _sendReviewNotification(
        session: session,
        reviewerId: reviewerId,
        reviewerNickname: reviewer?.nickname,
        revieweeId: request.revieweeId,
        rating: request.rating,
        productId: request.productId,
        chatRoomId: request.chatRoomId,
      ).catchError((error) {
        developer.log(
          '⚠️ 후기 FCM 알림 전송 실패 (무시): $error',
          name: 'ReviewService',
          error: error,
        );
      });

      // 7. 응답 DTO 생성
      return TransactionReviewResponseDto(
        id: createdReview.id!,
        productId: createdReview.productId,
        chatRoomId: createdReview.chatRoomId,
        reviewerId: createdReview.reviewerId,
        reviewerNickname: reviewer?.nickname,
        reviewerProfileImageUrl: reviewer?.profileImageUrl,
        revieweeId: createdReview.revieweeId,
        revieweeNickname: reviewee?.nickname,
        rating: createdReview.rating,
        content: createdReview.content,
        reviewType: createdReview.reviewType,
        createdAt: createdReview.createdAt,
      );
    } catch (e, stackTrace) {
      session.log(
        '❌ 거래 후기 작성 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 판매자에 대한 후기 작성 (구매자 → 판매자)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [reviewerId]는 리뷰 작성자 ID입니다 (구매자).
  /// [request]는 후기 작성 요청 정보입니다.
  /// 반환: 생성된 후기 응답 DTO
  static Future<TransactionReviewResponseDto> createSellerReview({
    required Session session,
    required int reviewerId,
    required CreateTransactionReviewRequestDto request,
  }) async {
    try {
      // 1. 평점 검증 (1~5)
      if (request.rating < 1 || request.rating > 5) {
        throw Exception('평점은 1~5 사이의 값이어야 합니다.');
      }

      // 2. 후기 내용 길이 검증 (최대 500자)
      if (request.content != null && request.content!.length > 500) {
        throw Exception('후기 내용은 최대 500자까지 입력 가능합니다.');
      }

      // 3. 중복 후기 확인
      final existingReview = await TransactionReview.db.findFirstRow(
        session,
        where: (review) =>
            review.productId.equals(request.productId) &
            review.chatRoomId.equals(request.chatRoomId) &
            review.reviewerId.equals(reviewerId) &
            review.reviewType.equals(ReviewType.buyer_to_seller),
      );

      if (existingReview != null) {
        throw Exception('이미 작성한 후기가 있습니다.');
      }

      // 4. 후기 생성
      final now = DateTime.now().toUtc();
      final review = TransactionReview(
        productId: request.productId,
        chatRoomId: request.chatRoomId,
        reviewerId: reviewerId,
        revieweeId: request.revieweeId,
        rating: request.rating,
        content: request.content,
        reviewType: ReviewType.buyer_to_seller,
        createdAt: now,
        updatedAt: now,
      );

      final createdReview = await TransactionReview.db.insertRow(
        session,
        review,
      );

      session.log(
        '✅ 판매자 후기 작성 완료: reviewId=${createdReview.id}, '
        'reviewerId=$reviewerId, revieweeId=${request.revieweeId}',
        level: LogLevel.info,
      );

      // 5. 사용자 정보 조회
      final reviewer = await User.db.findById(session, reviewerId);
      final reviewee = await User.db.findById(session, request.revieweeId);

      // 6. 응답 DTO 생성
      return TransactionReviewResponseDto(
        id: createdReview.id!,
        productId: createdReview.productId,
        chatRoomId: createdReview.chatRoomId,
        reviewerId: createdReview.reviewerId,
        reviewerNickname: reviewer?.nickname,
        reviewerProfileImageUrl: reviewer?.profileImageUrl,
        revieweeId: createdReview.revieweeId,
        revieweeNickname: reviewee?.nickname,
        rating: createdReview.rating,
        content: createdReview.content,
        reviewType: createdReview.reviewType,
        createdAt: createdReview.createdAt,
      );
    } catch (e, stackTrace) {
      session.log(
        '❌ 판매자 후기 작성 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 받은 후기 목록 조회 (페이지네이션)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [userId]는 조회할 사용자 ID입니다.
  /// [reviewType]는 조회할 후기 타입입니다 (구매자 후기 또는 판매자 후기).
  /// [page]는 페이지 번호입니다 (기본값: 1).
  /// [limit]는 페이지당 항목 수입니다 (기본값: 10).
  /// 반환: 후기 목록 응답 DTO
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

      // 4. 응답 DTO 생성
      final reviewDtos = <TransactionReviewResponseDto>[];
      for (final review in reviews) {
        final reviewer = await User.db.findById(session, review.reviewerId);
        final reviewee = await User.db.findById(session, review.revieweeId);

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
        '❌ 받은 후기 목록 조회 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 구매자 후기 목록 조회
  /// 판매자가 구매자에게 쓴 후기 (reviewType = seller_to_buyer)
  /// 구매자 입장에서 받은 후기
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [userId]는 조회할 사용자 ID입니다.
  /// [page]는 페이지 번호입니다 (기본값: 1).
  /// [limit]는 페이지당 항목 수입니다 (기본값: 10).
  /// 반환: 후기 목록 응답 DTO
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
  /// 구매자가 판매자에게 쓴 후기 (reviewType = buyer_to_seller)
  /// 판매자 입장에서 받은 후기
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [userId]는 조회할 사용자 ID입니다.
  /// [page]는 페이지 번호입니다 (기본값: 1).
  /// [limit]는 페이지당 항목 수입니다 (기본값: 10).
  /// 반환: 후기 목록 응답 DTO
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

  /// 거래 후기 삭제
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [reviewId]는 삭제할 후기 ID입니다.
  /// [userId]는 요청한 사용자 ID입니다.
  /// 반환: 삭제 성공 여부
  static Future<bool> deleteTransactionReview({
    required Session session,
    required int reviewId,
    required int userId,
  }) async {
    try {
      // 1. 후기 조회
      final review = await TransactionReview.db.findById(session, reviewId);

      if (review == null) {
        throw Exception('후기를 찾을 수 없습니다.');
      }

      // 2. 권한 확인 (본인이 작성한 후기만 삭제 가능)
      if (review.reviewerId != userId) {
        throw Exception('본인이 작성한 후기만 삭제할 수 있습니다.');
      }

      // 3. 후기 삭제
      await TransactionReview.db.deleteRow(session, review);

      session.log(
        '✅ 거래 후기 삭제 완료: reviewId=$reviewId, userId=$userId',
        level: LogLevel.info,
      );

      return true;
    } catch (e, stackTrace) {
      session.log(
        '❌ 거래 후기 삭제 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 상품 ID로 후기 삭제 (상품 상태 변경 시 사용)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [productId]는 상품 ID입니다.
  /// [userId]는 요청한 사용자 ID입니다 (상품 판매자).
  /// 반환: 삭제된 후기 개수
  static Future<int> deleteReviewsByProductId({
    required Session session,
    required int productId,
    required int userId,
  }) async {
    try {
      // 1. 상품 조회 및 권한 확인 (판매자만 삭제 가능)
      final product = await Product.db.findById(session, productId);
      if (product == null) {
        throw Exception('상품을 찾을 수 없습니다.');
      }

      if (product.sellerId != userId) {
        throw Exception('상품 판매자만 후기를 삭제할 수 있습니다.');
      }

      // 2. 해당 상품의 모든 후기 조회
      final reviews = await TransactionReview.db.find(
        session,
        where: (review) => review.productId.equals(productId),
      );

      if (reviews.isEmpty) {
        session.log(
          'ℹ️ 삭제할 후기가 없습니다: productId=$productId',
          level: LogLevel.info,
        );
        return 0;
      }

      // 3. 모든 후기 삭제
      int deletedCount = 0;
      for (final review in reviews) {
        await TransactionReview.db.deleteRow(session, review);
        deletedCount++;
      }

      session.log(
        '✅ 상품 후기 삭제 완료: productId=$productId, deletedCount=$deletedCount, userId=$userId',
        level: LogLevel.info,
      );

      return deletedCount;
    } catch (e, stackTrace) {
      session.log(
        '❌ 상품 후기 삭제 실패: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 후기 작성 시 FCM 알림 전송 (내부 헬퍼 메서드)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [reviewerId]는 후기 작성자 ID입니다.
  /// [reviewerNickname]은 후기 작성자 닉네임입니다.
  /// [revieweeId]는 후기 대상자 ID입니다.
  /// [rating]은 평점입니다.
  /// [productId]는 상품 ID입니다.
  /// [chatRoomId]는 채팅방 ID입니다.
  static Future<void> _sendReviewNotification({
    required Session session,
    required int reviewerId,
    String? reviewerNickname,
    required int revieweeId,
    required int rating,
    required int productId,
    required int chatRoomId,
  }) async {
    // Session이 닫힌 후에도 실행될 수 있으므로 안전한 로깅 헬퍼
    void safeLog(String message, {LogLevel level = LogLevel.info}) {
      try {
        session.log(message, level: level);
      } catch (e) {
        developer.log(message, name: 'ReviewService');
      }
    }

    try {
      safeLog('📱 후기 FCM 알림 전송 시작: revieweeId=$revieweeId, rating=$rating');

      // 1. 후기 대상자(reviewee)의 FCM 토큰 조회
      final fcmTokens = await FcmTokenService.getTokensByUserId(
        session: session,
        userId: revieweeId,
      );

      if (fcmTokens.isEmpty) {
        safeLog('⚠️ 후기 FCM 알림 전송 건너뜀: reviewee의 FCM 토큰이 없음');
        return;
      }

      // 2. 알림 제목 및 본문 생성
      final title = reviewerNickname ?? '알 수 없음';
      final starEmoji = '⭐' * rating;
      final body = '$starEmoji 거래 후기를 남겼습니다';

      // 3. 추가 데이터 설정 (딥링크를 위해 productId, chatRoomId 포함)
      final data = {
        'type': 'review_received',
        'reviewerId': reviewerId.toString(),
        'revieweeId': revieweeId.toString(),
        'productId': productId.toString(),
        'chatRoomId': chatRoomId.toString(),
        'rating': rating.toString(),
      };

      // 4. FCM 알림 전송
      await FcmService.sendNotifications(
        session: session,
        fcmTokens: fcmTokens,
        title: title,
        body: body,
        data: data,
        includeNotification: true,
      );

      safeLog(
          '✅ 후기 FCM 알림 전송 완료: revieweeId=$revieweeId, tokens=${fcmTokens.length}개');
    } catch (e, stackTrace) {
      safeLog(
        '❌ 후기 FCM 알림 전송 실패: $e',
        level: LogLevel.error,
      );
      developer.log(
        '❌ 후기 FCM 알림 전송 실패: $e',
        name: 'ReviewService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
