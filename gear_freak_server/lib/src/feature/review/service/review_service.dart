import 'dart:developer' as developer;

import 'package:gear_freak_server/src/common/fcm/service/fcm_service.dart';
import 'package:gear_freak_server/src/feature/notification/service/notification_service.dart';
import 'package:gear_freak_server/src/feature/user/service/fcm_token_service.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 리뷰 서비스
/// 후기 작성, 삭제, 존재 확인 관련 비즈니스 로직을 처리합니다.
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
        content: request.content,
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

      // 6. 📱 FCM 알림 전송 (비동기, 실패해도 후기 작성은 성공)
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
        '❌ 판매자 후기 작성 실패: $e',
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

      // 4. 📌 관련 알림 삭제 (비동기, 실패해도 후기 삭제는 성공)
      try {
        await NotificationService.deleteNotificationsByProductId(
          session: session,
          productId: productId,
        );
      } catch (error) {
        developer.log(
          '⚠️ 상품 후기 관련 알림 삭제 실패 (무시): $error',
          name: 'ReviewService',
          error: error,
        );
      }

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

  /// 리뷰 존재 여부 확인
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [productId]는 상품 ID입니다.
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [reviewerId]는 리뷰 작성자 ID입니다.
  /// [reviewType]는 리뷰 타입입니다.
  /// 반환: 리뷰가 존재하면 true, 없으면 false
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
        '❌ 리뷰 존재 여부 확인 실패: $e',
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

      // 5. 📌 notification 테이블에 저장 (알림 목록 화면에서 조회하기 위해)
      try {
        await NotificationService.createNotification(
          session: session,
          userId: revieweeId,
          notificationType: NotificationType.review_received,
          title: title,
          body: body,
          data: data,
        );
        safeLog('✅ 알림 DB 저장 완료: revieweeId=$revieweeId');
      } catch (error) {
        safeLog(
          '⚠️ 알림 DB 저장 실패 (무시): $error',
          level: LogLevel.warning,
        );
        developer.log(
          '⚠️ 알림 DB 저장 실패: $error',
          name: 'ReviewService',
          error: error,
        );
      }

      safeLog('✅ 알림 DB 저장 완료: revieweeId=$revieweeId');
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
