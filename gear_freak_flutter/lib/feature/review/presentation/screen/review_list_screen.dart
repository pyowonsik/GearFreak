import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/review/di/review_providers.dart';
import 'package:gear_freak_flutter/feature/review/presentation/provider/review_list_state.dart';

/// 후기 관리 화면
/// Presentation Layer: UI
class ReviewListScreen extends ConsumerStatefulWidget {
  /// ReviewListScreen 생성자
  const ReviewListScreen({super.key});

  @override
  ConsumerState<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends ConsumerState<ReviewListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('후기 관리'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF2563EB),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: '구매자 후기'),
            Tab(text: '판매자 후기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BuyerReviewsTab(),
          _SellerReviewsTab(),
        ],
      ),
    );
  }
}

/// 구매자 후기 탭
class _BuyerReviewsTab extends ConsumerStatefulWidget {
  const _BuyerReviewsTab();

  @override
  ConsumerState<_BuyerReviewsTab> createState() => _BuyerReviewsTabState();
}

class _BuyerReviewsTabState extends ConsumerState<_BuyerReviewsTab>
    with AutomaticKeepAliveClientMixin, PaginationScrollMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [BuyerReviewsTab] initState 호출');

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔄 [BuyerReviewsTab] 데이터 로드 시작');
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
            debugPrint(
                '📊 [BuyerReviews] Pagination: page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}, totalCount=${state.pagination.totalCount}');
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
        screenName: 'BuyerReviewsTab',
      );
      debugPrint(
          '📋 [BuyerReviewsTab] scrollController 생성됨: $scrollController');
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
    debugPrint('🎨 [BuyerReviewsTab] build, state: ${state.runtimeType}, '
        'scrollController: $scrollController');

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
            : _ReviewListView(
                reviews: reviews,
                isLoadingMore: state is ReviewListLoadingMore,
                scrollController: scrollController,
                onRefresh: () async {
                  await ref
                      .read(buyerReviewListNotifierProvider.notifier)
                      .loadReviews();
                },
              ),
    };
  }
}

/// 판매자 후기 탭
class _SellerReviewsTab extends ConsumerStatefulWidget {
  const _SellerReviewsTab();

  @override
  ConsumerState<_SellerReviewsTab> createState() => _SellerReviewsTabState();
}

class _SellerReviewsTabState extends ConsumerState<_SellerReviewsTab>
    with AutomaticKeepAliveClientMixin, PaginationScrollMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [SellerReviewsTab] initState 호출');

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔄 [SellerReviewsTab] 데이터 로드 시작');
      ref.read(sellerReviewListNotifierProvider.notifier).loadReviews();

      // 페이지네이션 초기화
      initPaginationScroll(
        onLoadMore: () {
          debugPrint('🔥 [SellerReviews] onLoadMore 호출됨!');
          ref.read(sellerReviewListNotifierProvider.notifier).loadMoreReviews();
        },
        getPagination: () {
          final state = ref.read(sellerReviewListNotifierProvider);
          if (state is ReviewListLoaded) {
            debugPrint(
                '📊 [SellerReviews] Pagination: page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}, totalCount=${state.pagination.totalCount}');
            return state.pagination;
          }
          if (state is ReviewListLoadingMore) {
            debugPrint(
                '📊 [SellerReviews] LoadingMore: page=${state.pagination.page}, '
                'hasMore=${state.pagination.hasMore}');
            return state.pagination;
          }
          debugPrint('⚠️ [SellerReviews] Pagination is null, state: $state');
          return null;
        },
        isLoading: () {
          final state = ref.read(sellerReviewListNotifierProvider);
          final loading = state is ReviewListLoadingMore;
          debugPrint('🔄 [SellerReviews] isLoading: $loading');
          return loading;
        },
        screenName: 'SellerReviewsTab',
      );
      debugPrint(
          '📋 [SellerReviewsTab] scrollController 생성됨: $scrollController');
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
    final state = ref.watch(sellerReviewListNotifierProvider);
    debugPrint('🎨 [SellerReviewsTab] build, state: ${state.runtimeType}, '
        'scrollController: $scrollController');

    return switch (state) {
      ReviewListInitial() || ReviewListLoading() => const GbLoadingView(),
      ReviewListError(:final message) => GbErrorView(
          message: message,
          onRetry: () {
            ref.read(sellerReviewListNotifierProvider.notifier).loadReviews();
          },
        ),
      ReviewListLoaded(:final reviews) ||
      ReviewListLoadingMore(:final reviews) =>
        reviews.isEmpty
            ? RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(sellerReviewListNotifierProvider.notifier)
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
                            Icons.edit_note_outlined,
                            size: 80,
                            color: Color(0xFFE5E7EB),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '판매자 후기가 없습니다',
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
            : _ReviewListView(
                reviews: reviews,
                isLoadingMore: state is ReviewListLoadingMore,
                scrollController: scrollController,
                onRefresh: () async {
                  await ref
                      .read(sellerReviewListNotifierProvider.notifier)
                      .loadReviews();
                },
              ),
    };
  }
}

/// 후기 목록 뷰
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
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 및 평점
          Row(
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF3F4F6),
                backgroundImage: review.reviewerProfileImageUrl != null
                    ? CachedNetworkImageProvider(
                        review.reviewerProfileImageUrl!)
                    : null,
                child: review.reviewerProfileImageUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 24,
                        color: Color(0xFF9CA3AF),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // 닉네임 및 날짜
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerNickname ?? '사용자',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),

              // 별점
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: index < review.rating
                        ? const Color(0xFFFFB800)
                        : const Color(0xFFE5E7EB),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 후기 내용
          if (review.content != null && review.content!.isNotEmpty)
            Text(
              review.content!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                height: 1.5,
              ),
            ),
          if (review.content != null && review.content!.isNotEmpty)
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks주 전';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months개월 전';
    } else {
      return '${date.year}.${date.month}.${date.day}';
    }
  }
}
