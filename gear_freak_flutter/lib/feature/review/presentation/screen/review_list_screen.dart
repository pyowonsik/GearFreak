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
    with SingleTickerProviderStateMixin, PaginationScrollMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 탭 변경 감지
    _tabController.addListener(_onTabChanged);

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    disposePaginationScroll();
    super.dispose();
  }

  /// 탭 변경 핸들러
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadInitialData();
    }
  }

  /// 초기 데이터 로드
  void _loadInitialData() {
    if (_tabController.index == 0) {
      // 구매자 후기
      ref.read(buyerReviewListNotifierProvider.notifier).loadReviews();
      _initPaginationForBuyer();
    } else {
      // 판매자 후기
      ref.read(sellerReviewListNotifierProvider.notifier).loadReviews();
      _initPaginationForSeller();
    }
  }

  /// 구매자 후기 페이지네이션 초기화
  void _initPaginationForBuyer() {
    initPaginationScroll(
      onLoadMore: () {
        ref.read(buyerReviewListNotifierProvider.notifier).loadMoreReviews();
      },
      getPagination: () {
        final state = ref.read(buyerReviewListNotifierProvider);
        if (state is ReviewListLoaded) {
          return state.pagination;
        }
        return null;
      },
      isLoading: () {
        final state = ref.read(buyerReviewListNotifierProvider);
        return state is ReviewListLoadingMore;
      },
      screenName: 'BuyerReviewsTab',
    );
  }

  /// 판매자 후기 페이지네이션 초기화
  void _initPaginationForSeller() {
    initPaginationScroll(
      onLoadMore: () {
        ref.read(sellerReviewListNotifierProvider.notifier).loadMoreReviews();
      },
      getPagination: () {
        final state = ref.read(sellerReviewListNotifierProvider);
        if (state is ReviewListLoaded) {
          return state.pagination;
        }
        return null;
      },
      isLoading: () {
        final state = ref.read(sellerReviewListNotifierProvider);
        return state is ReviewListLoadingMore;
      },
      screenName: 'SellerReviewsTab',
    );
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
class _BuyerReviewsTab extends ConsumerWidget {
  const _BuyerReviewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buyerReviewListNotifierProvider);

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
            ? const Center(
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
              )
            : _ReviewListView(
                reviews: reviews,
                isLoadingMore: state is ReviewListLoadingMore,
              ),
    };
  }
}

/// 판매자 후기 탭
class _SellerReviewsTab extends ConsumerWidget {
  const _SellerReviewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerReviewListNotifierProvider);

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
            ? const Center(
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
              )
            : _ReviewListView(
                reviews: reviews,
                isLoadingMore: state is ReviewListLoadingMore,
              ),
    };
  }
}

/// 후기 목록 뷰
class _ReviewListView extends StatelessWidget {
  const _ReviewListView({
    required this.reviews,
    required this.isLoadingMore,
  });

  final List<pod.TransactionReviewResponseDto> reviews;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reviews.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) {
        if (index == reviews.length - 1 && isLoadingMore) {
          return const SizedBox.shrink();
        }
        return const Divider(
          height: 1,
          thickness: 8,
          color: Color(0xFFF3F4F6),
        );
      },
      itemBuilder: (context, index) {
        if (index == reviews.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
          );
        }

        final review = reviews[index];
        return _ReviewItemWidget(review: review);
      },
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
