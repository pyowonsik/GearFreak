import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/view/profile_product_list_view.dart';

/// 다른 사용자의 상품 목록 화면
class OtherUserProductListScreen extends ConsumerStatefulWidget {
  /// OtherUserProductListScreen 생성자
  ///
  /// [userId]는 조회할 사용자의 ID입니다.
  const OtherUserProductListScreen({
    required this.userId,
    super.key,
  });

  /// 조회할 사용자 ID
  final String userId;

  @override
  ConsumerState<OtherUserProductListScreen> createState() =>
      _OtherUserProductListScreenState();
}

class _OtherUserProductListScreenState
    extends ConsumerState<OtherUserProductListScreen>
    with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [OtherUserProductListScreen] initState 호출');

    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = int.tryParse(widget.userId);
      if (userId != null) {
        debugPrint('🔄 [OtherUserProductListScreen] 데이터 로드 시작: userId=$userId');
        ref.read(otherUserProductListNotifierProvider(userId).notifier).loadProducts();

        // 페이지네이션 초기화
        initPaginationScroll(
          onLoadMore: () {
            debugPrint('🔥 [OtherUserProductListScreen] onLoadMore 호출됨!');
            ref
                .read(otherUserProductListNotifierProvider(userId).notifier)
                .loadMoreProducts();
          },
          getPagination: () {
            final state = ref.read(otherUserProductListNotifierProvider(userId));
            if (state is ProductPaginatedLoaded) {
              debugPrint('📊 [OtherUserProductListScreen] Pagination: '
                  'page=${state.pagination.page}, '
                  'hasMore=${state.pagination.hasMore}, '
                  'totalCount=${state.pagination.totalCount}');
              return state.pagination;
            }
            if (state is ProductPaginatedLoadingMore) {
              debugPrint(
                  '📊 [OtherUserProductListScreen] LoadingMore: page=${state.pagination.page}, '
                  'hasMore=${state.pagination.hasMore}');
              return state.pagination;
            }
            debugPrint(
                '⚠️ [OtherUserProductListScreen] Pagination is null, state: $state');
            return null;
          },
          isLoading: () {
            final state = ref.read(otherUserProductListNotifierProvider(userId));
            final loading = state is ProductPaginatedLoadingMore;
            debugPrint('🔄 [OtherUserProductListScreen] isLoading: $loading');
            return loading;
          },
          screenName: 'OtherUserProductListScreen',
        );
        debugPrint('📋 [OtherUserProductListScreen] '
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
        appBar: AppBar(title: const Text('상품 목록')),
        body: const Center(child: Text('잘못된 사용자 ID입니다.')),
      );
    }

    final state = ref.watch(otherUserProductListNotifierProvider(userId));
    debugPrint(
        '🎨 [OtherUserProductListScreen] build, state: ${state.runtimeType}, '
        'scrollController: $scrollController');

    return Scaffold(
      appBar: AppBar(
        title: const Text('판매중인 상품'),
      ),
      body: switch (state) {
        ProductInitial() || ProductLoading() => const GbLoadingView(),
        ProductError(:final message) => GbErrorView(
            message: message,
            onRetry: () {
              ref
                  .read(otherUserProductListNotifierProvider(userId).notifier)
                  .loadProducts();
            },
          ),
        ProductPaginatedLoaded(:final products, :final pagination) ||
        ProductPaginatedLoadingMore(:final products, :final pagination) =>
          ProfileProductListView(
              products: products,
              pagination: pagination,
              scrollController: scrollController ?? ScrollController(),
              isLoadingMore: state is ProductPaginatedLoadingMore,
              onRefresh: () async {
                await ref
                    .read(otherUserProductListNotifierProvider(userId).notifier)
                    .loadProducts();
              },
            ),
      },
    );
  }
}

