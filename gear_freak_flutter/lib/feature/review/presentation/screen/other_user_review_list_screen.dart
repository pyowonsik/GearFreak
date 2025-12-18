import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/review/di/review_providers.dart';
import 'package:gear_freak_flutter/feature/review/presentation/provider/review_list_state.dart';
import 'package:go_router/go_router.dart';

/// 다른 사용자의 모든 후기 목록 화면
class OtherUserReviewListScreen extends ConsumerStatefulWidget {
  /// OtherUserReviewListScreen 생성자
  ///
  /// [userId]는 조회할 사용자의 ID입니다.
  const OtherUserReviewListScreen({
    required this.userId,
    super.key,
  });

  /// 조회할 사용자 ID
  final String userId;

  @override
  ConsumerState<OtherUserReviewListScreen> createState() =>
      _OtherUserReviewListScreenState();
}

class _OtherUserReviewListScreenState
    extends ConsumerState<OtherUserReviewListScreen>
    with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [OtherUserReviewListScreen] initState 호출');

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = int.tryParse(widget.userId);
      if (userId != null) {
        debugPrint('🔄 [OtherUserReviewListScreen] 데이터 로드 시작: userId=$userId');
        ref
            .read(otherUserReviewListNotifierProvider(userId).notifier)
            .loadReviews();

        // 페이지네이션 초기화
        initPaginationScroll(
          onLoadMore: () {
            debugPrint('🔥 [OtherUserReviewListScreen] onLoadMore 호출됨!');
            ref
                .read(otherUserReviewListNotifierProvider(userId).notifier)
                .loadMoreReviews();
          },
          getPagination: () {
            final state = ref.read(otherUserReviewListNotifierProvider(userId));
            if (state is ReviewListLoaded) {
              debugPrint('📊 [OtherUserReviewListScreen] Pagination: '
                  'page=${state.pagination.page}, '
                  'hasMore=${state.pagination.hasMore}, '
                  'totalCount=${state.pagination.totalCount}');
              return state.pagination;
            }
            if (state is ReviewListLoadingMore) {
              debugPrint(
                  '📊 [OtherUserReviewListScreen] LoadingMore: page=${state.pagination.page}, '
                  'hasMore=${state.pagination.hasMore}');
              return state.pagination;
            }
            debugPrint(
                '⚠️ [OtherUserReviewListScreen] Pagination is null, state: $state');
            return null;
          },
          isLoading: () {
            final state = ref.read(otherUserReviewListNotifierProvider(userId));
            final loading = state is ReviewListLoadingMore;
            debugPrint('🔄 [OtherUserReviewListScreen] isLoading: $loading');
            return loading;
          },
          screenName: 'OtherUserReviewListScreen',
        );
        debugPrint('📋 [OtherUserReviewListScreen] '
            'scrollController 생성됨: $scrollController');
      }
    });
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = int.tryParse(widget.userId);
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('후기 목록')),
        body: const Center(child: Text('잘못된 사용자 ID입니다.')),
      );
    }

    final state = ref.watch(otherUserReviewListNotifierProvider(userId));
    debugPrint(
        '🎨 [OtherUserReviewListScreen] build, state: ${state.runtimeType}, '
        'scrollController: $scrollController');

    return Scaffold(
      appBar: AppBar(
        title: const Text('거래 후기'),
      ),
      body: switch (state) {
        ReviewListInitial() || ReviewListLoading() => const GbLoadingView(),
        ReviewListError(:final message) => GbErrorView(
            message: message,
            onRetry: () {
              ref
                  .read(otherUserReviewListNotifierProvider(userId).notifier)
                  .loadReviews();
            },
          ),
        ReviewListLoaded(:final reviews) ||
        ReviewListLoadingMore(:final reviews) =>
          reviews.isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(otherUserReviewListNotifierProvider(userId)
                            .notifier)
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
              : _ReviewListView(
                  reviews: reviews,
                  isLoadingMore: state is ReviewListLoadingMore,
                  scrollController: scrollController,
                  onRefresh: () async {
                    await ref
                        .read(otherUserReviewListNotifierProvider(userId)
                            .notifier)
                        .loadReviews();
                  },
                ),
      },
    );
  }
}

/// 후기 리스트 뷰
class _ReviewListView extends StatelessWidget {
  const _ReviewListView({
    required this.reviews,
    required this.isLoadingMore,
    required this.onRefresh,
    this.scrollController,
  });

  final List<pod.TransactionReviewResponseDto> reviews;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    debugPrint('📱 [_ReviewListView] build, reviews: ${reviews.length}, '
        'isLoadingMore: $isLoadingMore, scrollController: $scrollController');
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: reviews.length,
        separatorBuilder: (context, index) {
          return const Divider(
            height: 1,
            thickness: 8,
            color: Color(0xFFF3F4F6),
          );
        },
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _ReviewItemWidget(review: review);
        },
      ),
    );
  }
}

/// 후기 아이템 위젯
class _ReviewItemWidget extends StatelessWidget {
  const _ReviewItemWidget({required this.review});

  final pod.TransactionReviewResponseDto review;

  @override
  Widget build(BuildContext context) {
    final dateFormat = review.createdAt != null
        ? '${review.createdAt!.year}.'
            '${review.createdAt!.month.toString().padLeft(2, '0')}.'
            '${review.createdAt!.day.toString().padLeft(2, '0')}'
        : '';

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 및 평점
          Row(
            children: [
              // 프로필 이미지 (클릭 가능)
              GestureDetector(
                onTap: () {
                  // 리뷰 작성자 프로필 화면으로 이동
                  final reviewerId = review.reviewerId;
                  context.push('/profile/user/$reviewerId');
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFF3F4F6),
                  backgroundImage: review.reviewerProfileImageUrl != null
                      ? CachedNetworkImageProvider(
                          review.reviewerProfileImageUrl!,
                        )
                      : null,
                  child: review.reviewerProfileImageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 24,
                          color: Color(0xFF9CA3AF),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerNickname ?? '사용자',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 16,
                          color: i < review.rating
                              ? const Color(0xFFFFB800)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (dateFormat.isNotEmpty)
                Text(
                  dateFormat,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
          // 후기 내용
          if (review.content != null && review.content!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.content!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
