import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/paginated_products_list_widget.dart';

/// 카테고리별 상품 화면
class CategoryProductScreen extends ConsumerStatefulWidget {
  /// CategoryProductScreen 생성자
  ///
  /// [category]는 카테고리입니다.
  const CategoryProductScreen({required this.category, super.key});

  /// 카테고리
  final pod.ProductCategory category;

  @override
  ConsumerState<CategoryProductScreen> createState() =>
      _CategoryProductScreenState();
}

class _CategoryProductScreenState extends ConsumerState<CategoryProductScreen> {
  String _getCategoryName(pod.ProductCategory category) {
    switch (category) {
      case pod.ProductCategory.equipment:
        return '장비';
      case pod.ProductCategory.supplement:
        return '보충제';
      case pod.ProductCategory.clothing:
        return '의류';
      case pod.ProductCategory.shoes:
        return '신발';
      case pod.ProductCategory.etc:
        return '기타';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(categoryProductsNotifierProvider(widget.category).notifier)
          .loadPaginatedProductsByCategory(
            category: widget.category,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = categoryProductsNotifierProvider(widget.category);

    return PaginatedProductsListWidget(
      title: _getCategoryName(widget.category),
      productStateProvider: provider,
      onLoadMore: () {
        ref.read(provider.notifier).loadMoreProducts();
      },
      onRefresh: () async {
        final currentState = ref.read(provider);
        final sortBy =
            currentState is ProductPaginatedLoaded ? currentState.sortBy : null;
        await ref.read(provider.notifier).loadPaginatedProductsByCategory(
              category: widget.category,
              sortBy: sortBy,
            );
      },
      onRetry: () {
        final currentState = ref.read(provider);
        final sortBy =
            currentState is ProductPaginatedLoaded ? currentState.sortBy : null;
        ref.read(provider.notifier).loadPaginatedProductsByCategory(
              category: widget.category,
              sortBy: sortBy,
            );
      },
      onSortChanged: (sortBy) async {
        await ref.read(provider.notifier).loadPaginatedProductsByCategory(
              category: widget.category,
              sortBy: sortBy,
            );
      },
      screenName: 'CategoryProductScreen',
    );
  }
}
