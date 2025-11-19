import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/utils/pagination_scroll_mixin.dart';
import '../provider/product_state.dart';
import 'product_card_widget.dart';

/// 페이지네이션된 상품 목록 위젯
class PaginatedProductsListWidget extends ConsumerStatefulWidget {
  final String title;
  final ProviderListenable<ProductState> productStateProvider;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final String screenName;

  const PaginatedProductsListWidget({
    super.key,
    required this.title,
    required this.productStateProvider,
    required this.onLoadMore,
    required this.onRefresh,
    required this.onRetry,
    required this.screenName,
  });

  @override
  ConsumerState<PaginatedProductsListWidget> createState() =>
      _PaginatedProductsListWidgetState();
}

class _PaginatedProductsListWidgetState
    extends ConsumerState<PaginatedProductsListWidget>
    with PaginationScrollMixin {
  String _selectedSort = '최신순';

  @override
  void initState() {
    super.initState();
    initPaginationScroll(
      onLoadMore: widget.onLoadMore,
      getPagination: () {
        final productState = ref.read(widget.productStateProvider);
        if (productState is ProductPaginatedLoaded) {
          return productState.pagination;
        }
        return null;
      },
      isLoading: () {
        final productState = ref.read(widget.productStateProvider);
        return productState is ProductPaginatedLoadingMore;
      },
      screenName: widget.screenName,
    );
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(widget.productStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
        onRefresh: widget.onRefresh,
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
                    onPressed: widget.onRetry,
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

