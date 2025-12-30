import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/core/util/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/review/di/review_providers.dart';
import 'package:gear_freak_flutter/feature/review/presentation/presentation.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';

/// 구매자 후기 목록이 로드된 상태의 View
class BuyerReviewListLoadedView extends ConsumerStatefulWidget {
  /// BuyerReviewListLoadedView 생성자
  const BuyerReviewListLoadedView({
    required this.scrollController,
    super.key,
  });

  /// 스크롤 컨트롤러
  final ScrollController scrollController;

  @override
  ConsumerState<BuyerReviewListLoadedView> createState() =>
      _BuyerReviewListLoadedViewState();
}

class _BuyerReviewListLoadedViewState
    extends ConsumerState<BuyerReviewListLoadedView>
    with AutomaticKeepAliveClientMixin, PaginationScrollMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [BuyerReviewListLoadedView] initState 호출');

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔄 [BuyerReviewListLoadedView] 데이터 로드 시작');
      ref.read(buyerReviewListNotifierProvider.notifier).loadReviews();

      // 페이지네이션 초기화
      initPaginationScroll(
        onLoadMore: () {
          debugPrint('🔥 [BuyerReviews] onLoadMore 호출됨!');
          ref.read(buyerReviewListNotifierProvider.notifier).loadMoreReviews();
        },
        getPagination: () {
          final state = ref.read(buyerReviewListNotifierProvider);
          if (state is ReviewListLoaded) {
            debugPrint('📊 [BuyerReviews] Pagination: '
                'page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}, '
                'totalCount=${state.pagination.totalCount}');
            return state.pagination;
          }
          if (state is ReviewListLoadingMore) {
            debugPrint(
                '📊 [BuyerReviews] LoadingMore: page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}');
            return state.pagination;
          }
          debugPrint('⚠️ [BuyerReviews] Pagination is null, state: $state');
          return null;
        },
        isLoading: () {
          final state = ref.read(buyerReviewListNotifierProvider);
          final loading = state is ReviewListLoadingMore;
          debugPrint('🔄 [BuyerReviews] isLoading: $loading');
          return loading;
        },
        screenName: 'BuyerReviewListLoadedView',
      );
      debugPrint('📋 [BuyerReviewListLoadedView] '
          'scrollController 생성됨: ${widget.scrollController}');
    });
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수
    final state = ref.watch(buyerReviewListNotifierProvider);
    debugPrint(
        '🎨 [BuyerReviewListLoadedView] build, state: ${state.runtimeType}, '
        'scrollController: ${widget.scrollController}');

    return switch (state) {
      ReviewListInitial() || ReviewListLoading() => const GbLoadingView(),
      ReviewListError(:final message) => GbErrorView(
          message: message,
          onRetry: () {
            ref.read(buyerReviewListNotifierProvider.notifier).loadReviews();
          },
        ),
      ReviewListLoaded(:final reviews) ||
      ReviewListLoadingMore(:final reviews) =>
        reviews.isEmpty
            ? RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(buyerReviewListNotifierProvider.notifier)
                      .loadReviews();
                },
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 80,
                            color: Color(0xFFE5E7EB),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '구매자 후기가 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : ReviewListViewWidget(
                reviews: reviews,
                scrollController: widget.scrollController,
                onRefresh: () async {
                  await ref
                      .read(buyerReviewListNotifierProvider.notifier)
                      .loadReviews();
                },
              ),
    };
  }
}
