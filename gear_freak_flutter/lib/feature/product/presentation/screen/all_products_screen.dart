import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/paginated_products_list_widget.dart';

/// 전체 상품 화면
class AllProductsScreen extends ConsumerStatefulWidget {
  /// AllProductsScreen 생성자
  ///
  /// [key]는 위젯의 키입니다.
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
              limit: 20,
              sortBy: sortBy,
            );
      },
      onRetry: () {
        final currentState = ref.read(allProductsNotifierProvider);
        final sortBy =
            currentState is ProductPaginatedLoaded ? currentState.sortBy : null;
        ref.read(allProductsNotifierProvider.notifier).loadPaginatedProducts(
              limit: 20,
              sortBy: sortBy,
            );
      },
      onSortChanged: (sortBy) async {
        await ref
            .read(allProductsNotifierProvider.notifier)
            .loadPaginatedProducts(
              limit: 20,
              sortBy: sortBy,
            );
      },
      screenName: 'AllProductsScreen',
    );
  }
}
