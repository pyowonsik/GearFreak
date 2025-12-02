import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/view/view.dart';

/// 페이지네이션된 상품 목록 위젯
class PaginatedProductsListWidget extends ConsumerStatefulWidget {
  /// PaginatedProductsListWidget 생성자
  ///
  /// [title]는 상품 목록 제목입니다.
  /// [productStateProvider]는 상품 목록 상태 제공자입니다.
  /// [onLoadMore]는 더 많은 상품을 로드하는 콜백입니다.
  /// [onRefresh]는 상품 목록을 새로고침하는 콜백입니다.
  /// [onRetry]는 상품 목록을 다시 시도하는 콜백입니다.
  /// [screenName]는 화면 이름입니다.
  /// [onSortChanged]는 상품 정렬 옵션을 변경하는 콜백입니다.
  const PaginatedProductsListWidget({
    required this.title,
    required this.productStateProvider,
    required this.onLoadMore,
    required this.onRefresh,
    required this.onRetry,
    required this.screenName,
    super.key,
    this.onSortChanged,
  });

  /// 상품 목록 제목
  final String title;

  /// 상품 목록 상태 제공자
  final ProviderListenable<ProductState> productStateProvider;

  /// 더 많은 상품을 로드하는 콜백
  final VoidCallback onLoadMore;

  /// 상품 목록을 새로고침하는 콜백
  final Future<void> Function() onRefresh;

  /// 상품 목록을 다시 시도하는 콜백
  final VoidCallback onRetry;

  /// 화면 이름
  final String screenName;

  /// 상품 정렬 옵션을 변경하는 콜백
  final Future<void> Function(pod.ProductSortBy)? onSortChanged;

  @override
  ConsumerState<PaginatedProductsListWidget> createState() =>
      _PaginatedProductsListWidgetState();
}

class _PaginatedProductsListWidgetState
    extends ConsumerState<PaginatedProductsListWidget>
    with PaginationScrollMixin {
  String _selectedSort = '최신순';

  /// 정렬 옵션 문자열을 ProductSortBy enum으로 변환
  pod.ProductSortBy? _getSortByFromString(String sortString) {
    switch (sortString) {
      case '최신순':
        return pod.ProductSortBy.latest;
      case '인기순':
        return pod.ProductSortBy.popular;
      case '낮은 가격순':
        return pod.ProductSortBy.priceAsc;
      case '높은 가격순':
        return pod.ProductSortBy.priceDesc;
      default:
        return null;
    }
  }

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
            onSelected: (value) async {
              setState(() {
                _selectedSort = value;
              });
              // 정렬 옵션 변경 시 서버에 전달
              final sortBy = _getSortByFromString(value);
              if (sortBy != null && widget.onSortChanged != null) {
                await widget.onSortChanged!(sortBy);
              }
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
          ProductLoading() => const GbLoadingView(),
          ProductError(:final message) => GbErrorView(
              message: message,
              onRetry: widget.onRetry,
            ),
          ProductPaginatedLoaded(:final products, :final pagination) ||
          ProductPaginatedLoadingMore(:final products, :final pagination) =>
            PaginatedProductListView(
              key: const ValueKey('paginated_product_list'),
              products: products,
              pagination: pagination,
              scrollController: scrollController!,
              isLoadingMore: productState is ProductPaginatedLoadingMore,
            ),
          ProductInitial() => const GbLoadingView(),
        },
      ),
    );
  }
}
