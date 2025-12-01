import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/product/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/widget.dart';

/// 홈 화면이 로드된 상태의 View
class HomeLoadedView extends ConsumerWidget {
  /// HomeLoadedView 생성자
  ///
  /// [products]는 상품 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [sortBy]는 정렬 옵션입니다.
  /// [selectedCategory]는 선택된 카테고리입니다.
  /// [scrollController]는 스크롤 컨트롤러입니다.
  /// [onCategoryChanged]는 카테고리 변경 콜백입니다.
  /// [onSortChanged]는 정렬 변경 콜백입니다.
  /// [onRefresh]는 새로고침 콜백입니다.
  /// [isLoadingMore]는 더 불러오는 중인지 여부입니다.
  const HomeLoadedView({
    required this.products,
    required this.pagination,
    required this.sortBy,
    required this.selectedCategory,
    required this.scrollController,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onRefresh,
    this.isLoadingMore = false,
    super.key,
  });

  /// 상품 목록
  final List<pod.Product> products;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 정렬 옵션
  final pod.ProductSortBy? sortBy;

  /// 선택된 카테고리
  final pod.ProductCategory? selectedCategory;

  /// 스크롤 컨트롤러
  final ScrollController scrollController;

  /// 카테고리 변경 콜백
  final ValueChanged<pod.ProductCategory?> onCategoryChanged;

  /// 정렬 변경 콜백
  final ValueChanged<pod.ProductSortBy?> onSortChanged;

  /// 새로고침 콜백
  final Future<void> Function() onRefresh;

  /// 더 불러오는 중인지 여부
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 섹션
            CategoryFilterSectionComponent(
              selectedCategory: selectedCategory,
              onCategoryChanged: onCategoryChanged,
            ),
            const SizedBox(height: 8),
            // 상품 목록
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
                  if (products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: GbEmptyView(
                        message: '등록된 상품이 없습니다',
                      ),
                    )
                  else
                    Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return ProductCardWidget(
                              product: products[index],
                            );
                          },
                        ),
                        // 더 불러올 데이터가 있거나 로딩 중이면 로딩 인디케이터 표시
                        if (isLoadingMore || (pagination.hasMore ?? false))
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isLoadingMore ? 16 : 16,
                            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
