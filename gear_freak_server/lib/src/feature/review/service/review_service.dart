import 'dart:developer' as developer;

import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

import 'package:gear_freak_server/src/common/fcm/service/fcm_service.dart';

import 'package:gear_freak_server/src/feature/notification/service/notification_service.dart';
import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
import 'package:gear_freak_server/src/feature/chat/service/chat_notification_service.dart';

/// 리뷰 서비스
/// 후기 작성, 삭제, 존재 확인 관련 비즈니스 로직을 처리합니다.
class ReviewService {
  // ==================== Public Methods ====================

  /// 거래 후기 작성 (판매자 → 구매자)
  ///
  /// [session]: Serverpod 세션
  /// [reviewerId]: 리뷰 작성자 ID (판매자)
  /// [request]: 후기 작성 요청 DTO
  /// Returns: 생성된 후기 응답 DTO
  /// Throws: Exception - 평점 범위 오류, 내용 길이 초과, 중복 후기
  static Future<TransactionReviewResponseDto> createTransactionReview({
    required Session session,
    required int reviewerId,
    required CreateTransactionReviewRequestDto request,
  }) async {
    try {
      return await _createReview(
        session: session,
        reviewerId: reviewerId,
        request: request,
        reviewType: ReviewType.seller_to_buyer,
      );
    } catch (e, stackTrace) {
      session.log(
        '[ReviewService] createTransactionReview - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 판매자에 대한 후기 작성 (구매자 → 판매자)
  ///
  /// [session]: Serverpod 세션
  /// [reviewerId]: 리뷰 작성자 ID (구매자)
  /// [request]: 후기 작성 요청 DTO
  /// Returns: 생성된 후기 응답 DTO
  /// Throws: Exception - 평점 범위 오류, 내용 길이 초과, 중복 후기
  static Future<TransactionReviewResponseDto> createSellerReview({
    required Session session,
    required int reviewerId,
    required CreateTransactionReviewRequestDto request,
  }) async {
    try {
      return await _createReview(
        session: session,
        reviewerId: reviewerId,
        request: request,
        reviewType: ReviewType.buyer_to_seller,
      );
    } catch (e, stackTrace) {
      session.log(
        '[ReviewService] createSellerReview - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 상품 ID로 후기 삭제
  ///
  /// 상품 상태가 판매중으로 변경될 때 호출됩니다.
  /// 관련 알림도 함께 삭제됩니다.
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// [userId]: 요청자 ID (권한 확인용)
  /// Returns: 삭제된 후기 개수
  /// Throws: Exception - 상품 없음, 권한 없음
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
          '[ReviewService] deleteReviewsByProductId - info: no reviews to delete - productId=$productId',
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
        '[ReviewService] deleteReviewsByProductId - success: productId=$productId, deletedCount=$deletedCount, userId=$userId',
        level: LogLevel.info,
      );

      // 4. 관련 알림 삭제 (비동기, 실패해도 후기 삭제는 성공)
      try {
        await NotificationService.deleteNotificationsByProductId(
          session: session,
          productId: productId,
        );
      } catch (error) {
        developer.log(
          '[ReviewService] deleteReviewsByProductId - warning: notification deletion failed (ignored) - $error',
          name: 'ReviewService',
          error: error,
        );
      }

      return deletedCount;
    } catch (e, stackTrace) {
      session.log(
        '[ReviewService] deleteReviewsByProductId - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 리뷰 존재 여부 확인
  ///
  /// 중복 후기 방지를 위해 기존 후기가 있는지 확인합니다.
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// [chatRoomId]: 채팅방 ID
  /// [reviewerId]: 리뷰 작성자 ID
  /// [reviewType]: 리뷰 타입
  /// Returns: true = 존재, false = 없음
  static Future<bool> checkReviewExists({
    required Session session,
    required int productId,
    required int chatRoomId,
    required int reviewerId,
    required ReviewType reviewType,
  }) async {
    try {
      final existingReview = await TransactionReview.db.findFirstRow(
        session,
        where: (review) =>
            review.productId.equals(productId) &
            review.chatRoomId.equals(chatRoomId) &
            review.reviewerId.equals(reviewerId) &
            review.reviewType.equals(reviewType),
      );

      return existingReview != null;
    } catch (e, stackTrace) {
      session.log(
        '[ReviewService] checkReviewExists - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  // ==================== Private Helper Methods ====================

  /// 공통 후기 생성 로직
  ///
  /// 모든 후기 생성 메서드에서 사용하는 공통 로직입니다.
  ///
  /// [session]: Serverpod 세션
  /// [reviewerId]: 리뷰 작성자 ID
  /// [request]: 후기 작성 요청 DTO
  /// [reviewType]: 후기 타입 (seller_to_buyer 또는 buyer_to_seller)
  /// Returns: 생성된 후기 응답 DTO
  /// Throws: Exception - 평점 범위 오류, 내용 길이 초과, 중복 후기
  static Future<TransactionReviewResponseDto> _createReview({
    required Session session,
    required int reviewerId,
    required CreateTransactionReviewRequestDto request,
    required ReviewType reviewType,
  }) async {
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
          review.reviewType.equals(reviewType),
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
      reviewType: reviewType,
      createdAt: now,
      updatedAt: now,
    );

    final createdReview = await TransactionReview.db.insertRow(
      session,
      review,
    );

    session.log(
      '[ReviewService] _createReview - success: reviewId=${createdReview.id}, '
      'reviewerId=$reviewerId, revieweeId=${request.revieweeId}, reviewType=$reviewType',
      level: LogLevel.info,
    );

    // 5. 사용자 정보 조회
    final reviewer = await User.db.findById(session, reviewerId);
    final reviewee = await User.db.findById(session, request.revieweeId);

    // 6. FCM 알림 전송 (비동기, 실패해도 후기 작성은 성공)
    await _sendReviewNotification(
      session: session,
      reviewerId: reviewerId,
      reviewerNickname: reviewer?.nickname,
      revieweeId: request.revieweeId,
      rating: request.rating,
      productId: request.productId,
      chatRoomId: request.chatRoomId,
      content: request.content,
    ).catchError((error) {
      developer.log(
        '[ReviewService] _createReview - warning: FCM notification failed (ignored) - $error',
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
  }

  /// 후기 작성 시 FCM 알림 전송
  ///
  /// FCM 푸시 알림을 전송하고 notification 테이블에 저장합니다.
  ///
  /// [session]: Serverpod 세션
  /// [reviewerId]: 후기 작성자 ID
  /// [reviewerNickname]: 후기 작성자 닉네임
  /// [revieweeId]: 후기 대상자 ID
  /// [rating]: 평점
  /// [productId]: 상품 ID
  /// [chatRoomId]: 채팅방 ID
  /// [content]: 후기 내용
  static Future<void> _sendReviewNotification({
    required Session session,
    required int reviewerId,
    String? reviewerNickname,
    required int revieweeId,
    required int rating,
    required int productId,
    required int chatRoomId,
    String? content,
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
      safeLog('[ReviewService] _sendReviewNotification - start: revieweeId=$revieweeId, rating=$rating');

      // 1. 후기 대상자(reviewee)의 FCM 토큰 조회
      final fcmTokens = await FcmTokenService.getTokensByUserId(
        session: session,
        userId: revieweeId,
      );

      if (fcmTokens.isEmpty) {
        safeLog('[ReviewService] _sendReviewNotification - skip: no FCM tokens for reviewee');
        return;
      }

      // 2. 알림 제목 및 본문 생성
      final title = '거래후기';
      final reviewerName = reviewerNickname ?? '알 수 없음';

      // 리뷰 내용 처리 (16자 이상이면 자르고 "..." 추가)
      String reviewContent = content?.trim() ?? '';
      if (reviewContent.length > 16) {
        reviewContent = '${reviewContent.substring(0, 16)}...';
      }

      // 리뷰 내용이 있으면 따옴표로 감싸고, 없으면 빈 문자열
      final contentText = reviewContent.isNotEmpty ? '"$reviewContent" ' : '';

      final body = '$reviewerName님이 $contentText거래 후기를 남겨주셨습니다 !';

      // 3. 추가 데이터 설정 (딥링크를 위해 productId, chatRoomId 포함)
      final data = {
        'type': 'review_received',
        'reviewerId': reviewerId.toString(),
        'revieweeId': revieweeId.toString(),
        'productId': productId.toString(),
        'chatRoomId': chatRoomId.toString(),
        'rating': rating.toString(),
      };

      // 3.5. 읽지 않은 총 개수 계산 (badge용)
      final unreadChatCount = await ChatNotificationService()
          .getTotalUnreadChatCount(session, revieweeId);
      final unreadNotificationCount = await NotificationService.getUnreadCount(
        session: session,
        userId: revieweeId,
      );
      // 현재 알림도 포함해야 하므로 +1
      final totalBadge = unreadChatCount + unreadNotificationCount + 1;

      // 4. FCM 알림 전송
      await FcmService.sendNotifications(
        session: session,
        fcmTokens: fcmTokens,
        title: title,
        body: body,
        data: data,
        includeNotification: true,
        badge: totalBadge,
      );

      safeLog(
          '[ReviewService] _sendReviewNotification - success: FCM sent - revieweeId=$revieweeId, tokens=${fcmTokens.length}');

      // 5. notification 테이블에 저장 (알림 목록 화면에서 조회하기 위해)
      try {
        await NotificationService.createNotification(
          session: session,
          userId: revieweeId,
          notificationType: NotificationType.review_received,
          title: title,
          body: body,
          data: data,
        );
        safeLog('[ReviewService] _sendReviewNotification - success: notification saved - revieweeId=$revieweeId');
      } catch (error) {
        safeLog(
          '[ReviewService] _sendReviewNotification - warning: notification save failed (ignored) - $error',
          level: LogLevel.warning,
        );
        developer.log(
          '[ReviewService] _sendReviewNotification - warning: notification save failed - $error',
          name: 'ReviewService',
          error: error,
        );
      }

      safeLog('[ReviewService] _sendReviewNotification - completed: revieweeId=$revieweeId');
    } catch (e, stackTrace) {
      safeLog(
        '[ReviewService] _sendReviewNotification - error: $e',
        level: LogLevel.error,
      );
      developer.log(
        '[ReviewService] _sendReviewNotification - error: $e',
        name: 'ReviewService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
