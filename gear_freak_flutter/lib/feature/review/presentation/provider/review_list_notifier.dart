import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/get_buyer_reviews_usecase.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/get_seller_reviews_usecase.dart';
import 'package:gear_freak_flutter/feature/review/presentation/presentation.dart';

/// 리뷰 목록 Notifier (구매자 후기)
class BuyerReviewListNotifier extends StateNotifier<ReviewListState> {
  /// BuyerReviewListNotifier 생성자
  BuyerReviewListNotifier(this.getBuyerReviewsUseCase)
      : super(const ReviewListInitial());

  /// 구매자 후기 목록 조회 UseCase
  final GetBuyerReviewsUseCase getBuyerReviewsUseCase;

  /// 구매자 후기 목록 로드
  Future<void> loadReviews({int page = 1, int limit = 20}) async {
    state = const ReviewListLoading();

    final result = await getBuyerReviewsUseCase(
      GetBuyerReviewsParams(page: page, limit: limit),
    );

    result.fold(
      (failure) {
        debugPrint(
          '❌ [BuyerReviewListNotifier] 구매자 후기 목록 로드 실패: ${failure.message}',
        );
        state = ReviewListError(failure.message);
      },
      (response) {
        debugPrint('✅ [BuyerReviewListNotifier] 구매자 후기 목록 로드 성공: '
            'page=${response.pagination.page}, '
            'totalCount=${response.pagination.totalCount}, '
            'hasMore=${response.pagination.hasMore}, '
            'reviews=${response.reviews.length}개');
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
      debugPrint('⚠️ [ReceivedReviewListNotifier] loadMoreReviews: '
          '현재 상태가 ReviewListLoaded가 아닙니다. '
          '(${currentState.runtimeType})');
      return;
    }

    final currentPagination = currentState.pagination;

    if (currentPagination.hasMore != true) {
      debugPrint('⚠️ [ReceivedReviewListNotifier] loadMoreReviews:'
          ' 더 이상 불러올 데이터가 없습니다.');
      return;
    }

    if (state is ReviewListLoadingMore) {
      debugPrint('⚠️ [ReceivedReviewListNotifier] loadMoreReviews:'
          ' 이미 로딩 중입니다.');
      return;
    }

    final nextPage = currentPagination.page + 1;
    debugPrint('🔄 [ReceivedReviewListNotifier] 다음 페이지 로드: page=$nextPage '
        '(현재: ${currentPagination.page}, '
        '전체: ${currentPagination.totalCount})');

    state = ReviewListLoadingMore(
      reviews: currentState.reviews,
      pagination: currentPagination,
    );

    final result = await getBuyerReviewsUseCase(
      GetBuyerReviewsParams(
        page: nextPage,
        limit: currentPagination.limit,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [BuyerReviewListNotifier] 다음 페이지 로드 실패:'
            ' ${failure.message}');
        state = currentState;
      },
      (response) {
        final updatedReviews = [
          ...currentState.reviews,
          ...response.reviews,
        ];

        debugPrint('✅ [BuyerReviewListNotifier] 다음 페이지 로드 성공: '
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

/// 리뷰 목록 Notifier (판매자 후기)
class SellerReviewListNotifier extends StateNotifier<ReviewListState> {
  /// SellerReviewListNotifier 생성자
  SellerReviewListNotifier(this.getSellerReviewsUseCase)
      : super(const ReviewListInitial());

  /// 판매자 후기 목록 조회 UseCase
  final GetSellerReviewsUseCase getSellerReviewsUseCase;

  /// 판매자 후기 목록 로드
  Future<void> loadReviews({int page = 1, int limit = 20}) async {
    state = const ReviewListLoading();

    final result = await getSellerReviewsUseCase(
      GetSellerReviewsParams(page: page, limit: limit),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [SellerReviewListNotifier] 판매자 후기 목록 로드 실패: '
            '${failure.message}');
        state = ReviewListError(failure.message);
      },
      (response) {
        debugPrint('✅ [SellerReviewListNotifier] 판매자 후기 목록 로드 성공: '
            'page=${response.pagination.page}, '
            'totalCount=${response.pagination.totalCount}, '
            'hasMore=${response.pagination.hasMore}, '
            'reviews=${response.reviews.length}개');
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
      debugPrint('⚠️ [WrittenReviewListNotifier] loadMoreReviews: '
          '현재 상태가 ReviewListLoaded가 아닙니다. '
          '(${currentState.runtimeType})');
      return;
    }

    final currentPagination = currentState.pagination;

    if (currentPagination.hasMore != true) {
      debugPrint('⚠️ [WrittenReviewListNotifier] loadMoreReviews:'
          ' 더 이상 불러올 데이터가 없습니다.');
      return;
    }

    if (state is ReviewListLoadingMore) {
      debugPrint('⚠️ [WrittenReviewListNotifier] loadMoreReviews:'
          ' 이미 로딩 중입니다.');
      return;
    }

    final nextPage = currentPagination.page + 1;
    debugPrint('🔄 [WrittenReviewListNotifier] 다음 페이지 로드: '
        'page=$nextPage '
        '(현재: ${currentPagination.page}, '
        '전체: ${currentPagination.totalCount})');

    state = ReviewListLoadingMore(
      reviews: currentState.reviews,
      pagination: currentPagination,
    );

    final result = await getSellerReviewsUseCase(
      GetSellerReviewsParams(
        page: nextPage,
        limit: currentPagination.limit,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [SellerReviewListNotifier] 다음 페이지 로드 실패:'
            ' ${failure.message}');
        state = currentState;
      },
      (response) {
        final updatedReviews = [
          ...currentState.reviews,
          ...response.reviews,
        ];

        debugPrint('✅ [SellerReviewListNotifier] 다음 페이지 로드 성공: '
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
