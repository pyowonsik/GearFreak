import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 필터링 파라미터를 담는 클래스
class ProductFilterParams {
  final bool hasTitleFilter;
  final String? titleQuery;
  final bool hasCategoryFilter;
  final ProductCategory? category;

  ProductFilterParams({
    required this.hasTitleFilter,
    required this.titleQuery,
    required this.hasCategoryFilter,
    required this.category,
  });

  /// PaginationDto로부터 필터링 파라미터 생성
  factory ProductFilterParams.fromPaginationDto(PaginationDto pagination) {
    final hasTitleFilter =
        pagination.title != null && pagination.title!.trim().isNotEmpty;
    final titleQuery = hasTitleFilter ? '%${pagination.title!.trim()}%' : null;
    final hasCategoryFilter = pagination.category != null;
    final category = pagination.category;

    return ProductFilterParams(
      hasTitleFilter: hasTitleFilter,
      titleQuery: titleQuery,
      hasCategoryFilter: hasCategoryFilter,
      category: category,
    );
  }
}

/// Product 필터링 유틸리티
class ProductFilterUtil {
  /// 필터링 조건에 따른 where 절 생성
  static WhereExpressionBuilder<ProductTable>? buildWhereClause(
      ProductFilterParams params) {
    if (params.hasTitleFilter && params.hasCategoryFilter) {
      return (p) =>
          p.title.like(params.titleQuery!) &
          p.category.equals(params.category!);
    } else if (params.hasTitleFilter) {
      return (p) => p.title.like(params.titleQuery!);
    } else if (params.hasCategoryFilter) {
      return (p) => p.category.equals(params.category!);
    } else {
      return null;
    }
  }
}

/// Product 정렬 유틸리티
class ProductSortUtil {
  /// 정렬 기준에 따른 orderBy와 orderDescending 반환
  static (OrderByBuilder<ProductTable>, bool) getOrderByAndDescending(
      ProductSortBy sortBy) {
    switch (sortBy) {
      case ProductSortBy.latest:
        return ((p) => p.createdAt, true);
      case ProductSortBy.priceAsc:
        return ((p) => p.price, false);
      case ProductSortBy.priceDesc:
        return ((p) => p.price, true);
      case ProductSortBy.popular:
        // 찜 많은 순 (favoriteCount DESC)
        return ((p) => p.favoriteCount, true);
    }
  }
}
