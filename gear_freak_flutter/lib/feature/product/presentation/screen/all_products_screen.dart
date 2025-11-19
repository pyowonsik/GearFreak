import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/utils/pagination_scroll_mixin.dart';
import '../../di/product_providers.dart';
import '../provider/product_state.dart';
import '../widget/product_card_widget.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen>
    with PaginationScrollMixin {
  String _selectedSort = '최신순';

  @override
  void initState() {
    super.initState();
    initPaginationScroll(
      onLoadMore: () {
        ref.read(allProductsNotifierProvider.notifier).loadMoreProducts();
      },
      getPagination: () {
        final productState = ref.read(allProductsNotifierProvider);
        if (productState is ProductPaginatedLoaded) {
          return productState.pagination;
        }
        return null;
      },
      isLoading: () {
        final productState = ref.read(allProductsNotifierProvider);
        return productState is ProductPaginatedLoadingMore;
      },
      screenName: 'AllProductsScreen',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allProductsNotifierProvider.notifier).loadPaginatedProducts(
            page: 1,
            limit: 20,
          );
    });
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(allProductsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 상품'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedSort,
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
              // TODO: 정렬 기능 구현
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: '최신순',
                child: Text('최신순'),
              ),
              const PopupMenuItem(
                value: '인기순',
                child: Text('인기순'),
              ),
              const PopupMenuItem(
                value: '낮은 가격순',
                child: Text('낮은 가격순'),
              ),
              const PopupMenuItem(
                value: '높은 가격순',
                child: Text('높은 가격순'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _selectedSort,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(allProductsNotifierProvider.notifier)
              .loadPaginatedProducts(page: 1, limit: 20);
        },
        child: switch (productState) {
          ProductLoading() => const Center(child: CircularProgressIndicator()),
          ProductError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(allProductsNotifierProvider.notifier)
                          .loadPaginatedProducts(page: 1, limit: 20);
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ProductPaginatedLoaded(:final products, :final pagination) =>
            products.isEmpty
                ? const Center(
                    child: Text(
                      '등록된 상품이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        products.length + (pagination.hasMore == true ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == products.length) {
                        // 마지막에 로딩 인디케이터 표시
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return ProductCardWidget(
                        product: products[index],
                      );
                    },
                  ),
          ProductPaginatedLoadingMore(:final products) => ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: products.length + 1,
              itemBuilder: (context, index) {
                if (index == products.length) {
                  // 로딩 중 인디케이터 표시
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return ProductCardWidget(
                  product: products[index],
                );
              },
            ),
          ProductInitial() => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
