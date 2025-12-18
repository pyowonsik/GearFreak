import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/get_all_reviews_by_user_id_usecase.dart';
import 'package:gear_freak_flutter/feature/review/presentation/provider/review_list_state.dart';

/// 다른 사용자의 모든 후기 목록 Notifier
class OtherUserReviewListNotifier extends StateNotifier<ReviewListState> {
  /// OtherUserReviewListNotifier 생성자
  OtherUserReviewListNotifier(
    this.getAllReviewsByUserIdUseCase,
    this.userId,
  ) : super(const ReviewListInitial());

  /// 다른 사용자의 모든 후기 조회 UseCase
  final GetAllReviewsByUserIdUseCase getAllReviewsByUserIdUseCase;

  /// 조회할 사용자 ID
  final int userId;

  /// 후기 목록 로드
  Future<void> loadReviews({int page = 1, int limit = 20}) async {
    state = const ReviewListLoading();

    final result = await getAllReviewsByUserIdUseCase(
      GetAllReviewsByUserIdParams(
        userId: userId,
        page: page,
        limit: limit,
      ),
    );

    result.fold(
      (failure) {
        debugPrint(
          '❌ [OtherUserReviewListNotifier] 후기 목록 로드 실패: ${failure.message}',
        );
        state = ReviewListError(failure.message);
      },
      (response) {
        debugPrint('✅ [OtherUserReviewListNotifier] 후기 목록 로드 성공: '
            'page=${response.pagination.page}, '
            'totalCount=${response.pagination.totalCount}, '
            'hasMore=${response.pagination.hasMore}, '
            'reviews=${response.reviews.length}개, '
            'averageRating=${response.averageRating}');
        state = ReviewListLoaded(
          reviews: response.reviews,
          pagination: response.pagination,
        );
      },
    );
  }

  /// 더 많은 후기 불러오기
  Future<void> loadMoreReviews() async {
    final currentState = state;

    if (currentState is! ReviewListLoaded) {
      debugPrint('⚠️ [OtherUserReviewListNotifier] loadMoreReviews: '
          '현재 상태가 ReviewListLoaded가 아닙니다. '
          '(${currentState.runtimeType})');
      return;
    }

    final currentPagination = currentState.pagination;

    if (currentPagination.hasMore != true) {
      debugPrint('⚠️ [OtherUserReviewListNotifier] loadMoreReviews:'
          ' 더 이상 불러올 데이터가 없습니다.');
      return;
    }

    if (state is ReviewListLoadingMore) {
      debugPrint('⚠️ [OtherUserReviewListNotifier] loadMoreReviews:'
          ' 이미 로딩 중입니다.');
      return;
    }

    final nextPage = currentPagination.page + 1;
    debugPrint('🔄 [OtherUserReviewListNotifier] 다음 페이지 로드: page=$nextPage '
        '(현재: ${currentPagination.page}, '
        '전체: ${currentPagination.totalCount})');

    state = ReviewListLoadingMore(
      reviews: currentState.reviews,
      pagination: currentPagination,
    );

    final result = await getAllReviewsByUserIdUseCase(
      GetAllReviewsByUserIdParams(
        userId: userId,
        page: nextPage,
        limit: currentPagination.limit,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [OtherUserReviewListNotifier] 다음 페이지 로드 실패:'
            ' ${failure.message}');
        state = currentState;
      },
      (response) {
        final updatedReviews = [
          ...currentState.reviews,
          ...response.reviews,
        ];

        debugPrint('✅ [OtherUserReviewListNotifier] 다음 페이지 로드 성공: '
            'page=${response.pagination.page}, '
            '추가된 후기=${response.reviews.length}개, '
            '총 후기=${updatedReviews.length}개, '
            'hasMore=${response.pagination.hasMore}');

        state = ReviewListLoaded(
          reviews: updatedReviews,
          pagination: response.pagination,
        );
      },
    );
  }
}
