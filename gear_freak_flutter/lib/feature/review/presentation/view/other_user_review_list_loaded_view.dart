import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/core/util/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/review/di/review_providers.dart';
import 'package:gear_freak_flutter/feature/review/presentation/presentation.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';

/// 다른 사용자 후기 목록이 로드된 상태의 View
class OtherUserReviewListLoadedView extends ConsumerStatefulWidget {
  /// OtherUserReviewListLoadedView 생성자
  ///
  /// [userId]는 조회할 사용자의 ID입니다.
  /// [scrollController]는 스크롤 컨트롤러입니다.
  const OtherUserReviewListLoadedView({
    required this.userId,
    required this.scrollController,
    super.key,
  });

  /// 조회할 사용자 ID
  final int userId;

  /// 스크롤 컨트롤러
  final ScrollController scrollController;

  @override
  ConsumerState<OtherUserReviewListLoadedView> createState() =>
      _OtherUserReviewListLoadedViewState();
}

class _OtherUserReviewListLoadedViewState
    extends ConsumerState<OtherUserReviewListLoadedView>
    with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [OtherUserReviewListLoadedView] initState 호출');

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '🔄 [OtherUserReviewListLoadedView] 데이터 로드 시작: userId=${widget.userId}',
      );
      ref
          .read(otherUserReviewListNotifierProvider(widget.userId).notifier)
          .loadReviews();

      // 페이지네이션 초기화
      initPaginationScroll(
        onLoadMore: () {
          debugPrint('🔥 [OtherUserReviewListLoadedView] onLoadMore 호출됨!');
          ref
              .read(otherUserReviewListNotifierProvider(widget.userId).notifier)
              .loadMoreReviews();
        },
        getPagination: () {
          final state =
              ref.read(otherUserReviewListNotifierProvider(widget.userId));
          if (state is ReviewListLoaded) {
            debugPrint('📊 [OtherUserReviewListLoadedView] Pagination: '
                'page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}, '
                'totalCount=${state.pagination.totalCount}');
            return state.pagination;
          }
          if (state is ReviewListLoadingMore) {
            debugPrint('📊 [OtherUserReviewListLoadedView]'
                ' LoadingMore: page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}');
            return state.pagination;
          }
          debugPrint('⚠️ [OtherUserReviewListLoadedView]'
              ' Pagination is null, state: $state');
          return null;
        },
        isLoading: () {
          final state =
              ref.read(otherUserReviewListNotifierProvider(widget.userId));
          final loading = state is ReviewListLoadingMore;
          debugPrint('🔄 [OtherUserReviewListLoadedView] isLoading: $loading');
          return loading;
        },
        screenName: 'OtherUserReviewListLoadedView',
      );
      debugPrint('📋 [OtherUserReviewListLoadedView] '
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
    final state = ref.watch(otherUserReviewListNotifierProvider(widget.userId));
    debugPrint('🎨 [OtherUserReviewListLoadedView] build, '
        'state: ${state.runtimeType}, '
        'scrollController: ${widget.scrollController}');

    return switch (state) {
      ReviewListInitial() || ReviewListLoading() => const GbLoadingView(),
      ReviewListError(:final message) => GbErrorView(
          message: message,
          onRetry: () {
            ref
                .read(
                  otherUserReviewListNotifierProvider(widget.userId).notifier,
                )
                .loadReviews();
          },
        ),
      ReviewListLoaded(:final reviews) ||
      ReviewListLoadingMore(:final reviews) =>
        reviews.isEmpty
            ? RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(
                        otherUserReviewListNotifierProvider(widget.userId)
                            .notifier,
                      )
                      .loadReviews();
                },
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        '등록된 후기가 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : OtherUserReviewListViewWidget(
                reviews: reviews,
                scrollController: widget.scrollController,
                onRefresh: () async {
                  await ref
                      .read(
                        otherUserReviewListNotifierProvider(widget.userId)
                            .notifier,
                      )
                      .loadReviews();
                },
              ),
    };
  }
}
