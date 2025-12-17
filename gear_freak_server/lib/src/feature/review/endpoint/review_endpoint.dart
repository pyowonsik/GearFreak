import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:gear_freak_server/src/feature/review/service/review_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';
import 'package:serverpod/serverpod.dart';

/// 리뷰 엔드포인트
class ReviewEndpoint extends Endpoint {
  /// 거래 후기 작성
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [request]는 후기 작성 요청 정보입니다.
  /// 반환: 생성된 후기 응답 DTO
  Future<TransactionReviewResponseDto> createTransactionReview(
    Session session,
    CreateTransactionReviewRequestDto request,
  ) async {
    // 인증 확인 및 User 테이블의 실제 ID 가져오기
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await ReviewService.createTransactionReview(
      session: session,
      reviewerId: user.id!,
      request: request,
    );
  }

  /// 구매자 후기 목록 조회 (페이지네이션)
  /// 구매자가 나에게 쓴 후기 (reviewType = buyer_to_seller)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [page]는 페이지 번호입니다 (기본값: 1).
  /// [limit]는 페이지당 항목 수입니다 (기본값: 10).
  /// 반환: 후기 목록 응답 DTO
  Future<TransactionReviewListResponseDto> getBuyerReviews(
    Session session, {
    int page = 1,
    int limit = 10,
  }) async {
    // 인증 확인 및 User 테이블의 실제 ID 가져오기
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await ReviewService.getBuyerReviews(
      session: session,
      userId: user.id!,
      page: page,
      limit: limit,
    );
  }

  /// 판매자 후기 목록 조회 (페이지네이션)
  /// 판매자가 나에게 쓴 후기 (reviewType = seller_to_buyer)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [page]는 페이지 번호입니다 (기본값: 1).
  /// [limit]는 페이지당 항목 수입니다 (기본값: 10).
  /// 반환: 후기 목록 응답 DTO
  Future<TransactionReviewListResponseDto> getSellerReviews(
    Session session, {
    int page = 1,
    int limit = 10,
  }) async {
    // 인증 확인 및 User 테이블의 실제 ID 가져오기
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await ReviewService.getSellerReviews(
      session: session,
      userId: user.id!,
      page: page,
      limit: limit,
    );
  }

  /// 판매자에 대한 후기 작성 (구매자 → 판매자)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [request]는 후기 작성 요청 정보입니다.
  /// 반환: 생성된 후기 응답 DTO
  Future<TransactionReviewResponseDto> createSellerReview(
    Session session,
    CreateTransactionReviewRequestDto request,
  ) async {
    // 인증 확인 및 User 테이블의 실제 ID 가져오기
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await ReviewService.createSellerReview(
      session: session,
      reviewerId: user.id!,
      request: request,
    );
  }

  /// 상품 ID로 후기 삭제 (상품 상태 변경 시 사용)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [productId]는 상품 ID입니다.
  /// 반환: 삭제된 후기 개수
  Future<int> deleteReviewsByProductId(
    Session session,
    int productId,
  ) async {
    // 인증 확인 및 User 테이블의 실제 ID 가져오기
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await ReviewService.deleteReviewsByProductId(
      session: session,
      productId: productId,
      userId: user.id!,
    );
  }
}
