import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/product/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/widget.dart';

/// 검색 결과가 로드된 상태의 View
class SearchLoadedView extends ConsumerWidget {
  /// SearchLoadedView 생성자
  ///
  /// [products]는 검색 결과 상품 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [query]는 검색어입니다.
  /// [sortBy]는 정렬 옵션입니다.
  /// [scrollController]는 스크롤 컨트롤러입니다.
  /// [onSortChanged]는 정렬 변경 콜백입니다.
  /// [onRefresh]는 새로고침 콜백입니다.
  /// [isLoadingMore]는 더 불러오는 중인지 여부입니다.
  const SearchLoadedView({
    required this.products,
    required this.pagination,
    required this.query,
    required this.sortBy,
    required this.scrollController,
    required this.onSortChanged,
    required this.onRefresh,
    this.isLoadingMore = false,
    super.key,
  });

  /// 검색 결과 상품 목록
  final List<pod.Product> products;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 검색어
  final String query;

  /// 정렬 옵션
  final pod.ProductSortBy? sortBy;

  /// 스크롤 컨트롤러
  final ScrollController scrollController;

  /// 정렬 변경 콜백
  final ValueChanged<pod.ProductSortBy?> onSortChanged;

  /// 새로고침 콜백
  final Future<void> Function() onRefresh;

  /// 더 불러오는 중인지 여부
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const GbEmptyView(
        icon: Icons.search_off,
        message: '검색 결과가 없습니다',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 결과 목록
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductSortHeaderComponent(
                    totalCount: pagination.totalCount ?? 0,
                    sortBy: sortBy,
                    onSortChanged: onSortChanged,
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCardWidget(product: product);
                    },
                  ),
                  // 더 불러올 데이터가 있거나 로딩 중이면 로딩 인디케이터 표시
                  if (isLoadingMore || (pagination.hasMore ?? false))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: isLoadingMore
                            ? const CircularProgressIndicator()
                            : const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
