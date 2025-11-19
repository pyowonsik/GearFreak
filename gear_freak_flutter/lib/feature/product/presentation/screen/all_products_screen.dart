import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/product_providers.dart';
import '../provider/product_state.dart';
import '../widget/paginated_products_list_widget.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allProductsNotifierProvider.notifier).loadPaginatedProducts(
            page: 1,
            limit: 20,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedProductsListWidget(
      title: '전체 상품',
      productStateProvider: allProductsNotifierProvider,
      onLoadMore: () {
        ref.read(allProductsNotifierProvider.notifier).loadMoreProducts();
      },
      onRefresh: () async {
        final currentState = ref.read(allProductsNotifierProvider);
        final sortBy =
            currentState is ProductPaginatedLoaded ? currentState.sortBy : null;
        await ref
            .read(allProductsNotifierProvider.notifier)
            .loadPaginatedProducts(
              page: 1,
              limit: 20,
              sortBy: sortBy,
            );
      },
      onRetry: () {
        final currentState = ref.read(allProductsNotifierProvider);
        final sortBy =
            currentState is ProductPaginatedLoaded ? currentState.sortBy : null;
        ref.read(allProductsNotifierProvider.notifier).loadPaginatedProducts(
              page: 1,
              limit: 20,
              sortBy: sortBy,
            );
      },
      onSortChanged: (sortBy) async {
        await ref
            .read(allProductsNotifierProvider.notifier)
            .loadPaginatedProducts(
              page: 1,
              limit: 20,
              sortBy: sortBy,
            );
      },
      screenName: 'AllProductsScreen',
    );
  }
}
