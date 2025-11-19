import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../di/product_providers.dart';
import '../widget/paginated_products_list_widget.dart';

/// 카테고리별 상품 화면
class CategoryProductScreen extends ConsumerStatefulWidget {
  final pod.ProductCategory category;

  const CategoryProductScreen({
    super.key,
    required this.category,
  });

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
            page: 1,
            limit: 20,
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
        await ref.read(provider.notifier).loadPaginatedProductsByCategory(
              category: widget.category,
              page: 1,
              limit: 20,
            );
      },
      onRetry: () {
        ref.read(provider.notifier).loadPaginatedProductsByCategory(
              category: widget.category,
              page: 1,
              limit: 20,
            );
      },
      screenName: 'CategoryProductScreen',
    );
  }
}
