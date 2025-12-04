import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/view/view.dart';

/// 홈 화면
class HomeScreen extends ConsumerStatefulWidget {
  /// HomeScreen 생성자
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with PaginationScrollMixin {
  pod.ProductCategory? _selectedCategory; // null이면 전체

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 [HomeScreen] initState 실행');

    // 무한 스크롤 초기화
    initPaginationScroll(
      onLoadMore: () {
        ref.read(productNotifierProvider.notifier).loadMoreProducts();
      },
      getPagination: () {
        final productState = ref.read(productNotifierProvider);
        if (productState is ProductPaginatedLoaded) {
          return productState.pagination;
        }
        return null;
      },
      isLoading: () {
        final productState = ref.read(productNotifierProvider);
        return productState is ProductPaginatedLoadingMore;
      },
      screenName: 'HomeScreen',
    );

    // 초기 상품 목록 로드 (전체)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  /// 카테고리 및 정렬에 따라 상품 로드
  Future<void> _loadProducts({pod.ProductSortBy? sortBy}) async {
    if (_selectedCategory == null) {
      // 전체
      await ref.read(productNotifierProvider.notifier).loadPaginatedProducts(
            limit: 20,
            sortBy: sortBy,
          );
    } else {
      // 특정 카테고리
      await ref
          .read(productNotifierProvider.notifier)
          .loadPaginatedProductsByCategory(
            category: _selectedCategory!,
            sortBy: sortBy,
          );
    }
  }

  @override
  void dispose() {
    debugPrint('🏠 [HomeScreen] dispose 실행');
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: GbAppBar(
        title: const Text('운동은 장비충'),
        prefix: Icon(
          Icons.shopping_bag,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: 알림 화면으로 이동
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: switch (productState) {
        ProductLoading() => const GbLoadingView(),
        ProductError(:final message) => GbErrorView(
            message: message,
            onRetry: () {
              ref
                  .read(productNotifierProvider.notifier)
                  .loadPaginatedProducts(limit: 20);
            },
          ),
        ProductPaginatedLoaded(
          :final products,
          :final pagination,
          :final sortBy
        ) ||
        ProductPaginatedLoadingMore(
          :final products,
          :final pagination,
          :final sortBy
        ) =>
          HomeLoadedView(
            key: const ValueKey('home_loaded'),
            products: products,
            pagination: pagination,
            sortBy: sortBy,
            selectedCategory: _selectedCategory,
            scrollController: scrollController!,
            isLoadingMore: productState is ProductPaginatedLoadingMore,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
              _loadProducts(sortBy: sortBy);
            },
            onSortChanged: (newSortBy) async {
              await _loadProducts(sortBy: newSortBy);
            },
            onRefresh: () async {
              await _loadProducts(sortBy: sortBy);
            },
          ),
        ProductInitial() => const GbLoadingView(),
      },
    );
  }
}
