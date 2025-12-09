import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/view/profile_product_list_view.dart';

/// 프로필 상품 목록 화면 (내 상품 / 찜 목록 / 거래완료)
class ProfileProductsScreen extends ConsumerStatefulWidget {
  /// ProfileProductsScreen 생성자
  ///
  /// [type]는 "myProducts" (내 상품), "mySoldProducts" (거래완료),
  /// 또는 "myFavorite" (찜 목록)입니다.
  const ProfileProductsScreen({
    required this.type,
    super.key,
  });

  /// 상품 목록 타입
  final String type;

  @override
  ConsumerState<ProfileProductsScreen> createState() =>
      _ProfileProductsScreenState();
}

class _ProfileProductsScreenState extends ConsumerState<ProfileProductsScreen>
    with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();

    // 무한 스크롤 초기화
    initPaginationScroll(
      onLoadMore: () {
        ref
            .read(profileProductNotifierProvider(widget.type).notifier)
            .loadMoreProducts();
      },
      getPagination: () {
        final productState =
            ref.read(profileProductNotifierProvider(widget.type));
        if (productState is ProductPaginatedLoaded) {
          return productState.pagination;
        }
        return null;
      },
      isLoading: () {
        final productState =
            ref.read(profileProductNotifierProvider(widget.type));
        return productState is ProductPaginatedLoadingMore;
      },
      screenName: 'ProfileProductsScreen',
    );

    // 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  /// 데이터 로드
  void _loadData() {
    final notifier = ref.read(
      profileProductNotifierProvider(widget.type).notifier,
    );

    if (widget.type == 'myProducts') {
      // 판매중 상품만 조회
      notifier.loadMyProducts(status: pod.ProductStatus.selling);
    } else if (widget.type == 'mySoldProducts') {
      // 거래완료 상품만 조회
      notifier.loadMyProducts(status: pod.ProductStatus.sold);
    } else if (widget.type == 'myFavorite') {
      notifier.loadMyFavoriteProducts();
    }
  }

  /// 새로고침
  Future<void> _onRefresh() async {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(profileProductNotifierProvider(widget.type));

    final title = switch (widget.type) {
      'myProducts' => '내 상품 관리',
      'mySoldProducts' => '거래완료',
      'myFavorite' => '관심 목록',
      _ => '상품 목록',
    };

    return Scaffold(
      appBar: GbAppBar(
        title: Text(title),
      ),
      body: switch (productState) {
        ProductInitial() || ProductLoading() => const GbLoadingView(),
        ProductError(:final message) => GbErrorView(
            message: message,
            onRetry: _loadData,
          ),
        ProductPaginatedLoaded(
          :final products,
          :final pagination,
        ) ||
        ProductPaginatedLoadingMore(
          :final products,
          :final pagination,
        ) =>
          ProfileProductListView(
            products: products,
            pagination: pagination,
            scrollController: scrollController!,
            onRefresh: _onRefresh,
            isLoadingMore: productState is ProductPaginatedLoadingMore,
          ),
      },
    );
  }
}
