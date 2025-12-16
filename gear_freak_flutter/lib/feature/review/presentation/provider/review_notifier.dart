import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/review/domain/usecase/create_transaction_review_usecase.dart';

/// 리뷰 Notifier
/// Presentation Layer: Riverpod 상태 관리
class ReviewNotifier extends StateNotifier<ReviewState> {
  /// ReviewNotifier 생성자
  ///
  /// [createTransactionReviewUseCase]는 거래 후기 작성 UseCase입니다.
  ReviewNotifier(this.createTransactionReviewUseCase)
      : super(const ReviewInitial());

  /// 거래 후기 작성 UseCase
  final CreateTransactionReviewUseCase createTransactionReviewUseCase;

  /// 구매자 후기 작성 (판매자 → 구매자)
  ///
  /// [productId]는 상품 ID입니다.
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [revieweeId]는 리뷰 대상자 ID (구매자 ID)입니다.
  /// [rating]는 평점 (1~5)입니다.
  /// [content]는 후기 내용입니다 (선택사항).
  Future<bool> createBuyerReview({
    required int productId,
    required int chatRoomId,
    required int revieweeId,
    required int rating,
    String? content,
  }) async {
    try {
      _safeSetState(const ReviewLoading());

      final result = await createTransactionReviewUseCase(
        CreateTransactionReviewParams(
          productId: productId,
          chatRoomId: chatRoomId,
          revieweeId: revieweeId,
          rating: rating,
          content: content,
        ),
      );

      return result.fold(
        (failure) {
          debugPrint('❌ [ReviewNotifier] 구매자 후기 작성 실패: ${failure.message}');
          _safeSetState(ReviewError(failure.message));
          return false;
        },
        (review) {
          debugPrint('✅ [ReviewNotifier] 구매자 후기 작성 성공: reviewId=${review.id}');
          _safeSetState(ReviewSuccess(review));
          return true;
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [ReviewNotifier] 구매자 후기 작성 예외 발생: $e');
      debugPrint('Stack trace: $stackTrace');
      _safeSetState(ReviewError('후기 작성에 실패했습니다: $e'));
      return false;
    }
  }

  /// 안전하게 상태 업데이트
  void _safeSetState(ReviewState newState) {
    try {
      state = newState;
    } catch (e) {
      debugPrint('⚠️ [ReviewNotifier] 상태 업데이트 실패 (무시): $e');
    }
  }
}

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
