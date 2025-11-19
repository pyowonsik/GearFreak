import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/product_providers.dart';
import '../provider/product_state.dart';
import '../widget/product_card_widget.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedSort = '최신순';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allProductsNotifierProvider.notifier).loadPaginatedProducts(
            page: 1,
            limit: 10,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 스크롤 컨트롤러가 초기화되지 않았으면 무시
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    // 스크롤 가능한 상태인지 확인
    if (!position.hasContentDimensions) {
      return;
    }

    // 스크롤이 하단 300px 이내에 도달하면 다음 페이지 로드
    final threshold = position.maxScrollExtent - 300;
    if (position.pixels >= threshold && position.pixels > 0) {
      final productState = ref.read(allProductsNotifierProvider);

      // 페이지네이션된 상태이고, 로딩 중이 아니고, 더 불러올 데이터가 있을 때만 로드
      if (productState is ProductPaginatedLoaded) {
        final pagination = productState.pagination;
        if (pagination.hasMore == true) {
          print(
              '📜 [AllProductsScreen] 스크롤 감지: pixels=${position.pixels.toStringAsFixed(0)}, maxScrollExtent=${position.maxScrollExtent.toStringAsFixed(0)}, threshold=${threshold.toStringAsFixed(0)}');
          print(
              '📦 [AllProductsScreen] 현재 페이지: ${pagination.page}, 전체: ${pagination.totalCount}, hasMore: ${pagination.hasMore}');
          ref.read(allProductsNotifierProvider.notifier).loadMoreProducts();
        } else {
          print('✅ [AllProductsScreen] 더 이상 불러올 데이터가 없습니다.');
        }
      }
    }
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
              .loadPaginatedProducts(page: 1, limit: 10);
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
                          .loadPaginatedProducts(page: 1, limit: 10);
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
                    controller: _scrollController,
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
              controller: _scrollController,
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
