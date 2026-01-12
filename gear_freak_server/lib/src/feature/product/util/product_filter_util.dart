import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 필터링 파라미터를 담는 클래스
class ProductFilterParams {
  final bool hasTitleFilter;
  final String? titleQuery;
  final bool hasCategoryFilter;
  final ProductCategory? category;
  final bool excludeSold; // 판매완료 상품 제외 여부

  ProductFilterParams({
    required this.hasTitleFilter,
    required this.titleQuery,
    required this.hasCategoryFilter,
    required this.category,
    this.excludeSold = false,
  });

  /// PaginationDto로부터 필터링 파라미터 생성
  factory ProductFilterParams.fromPaginationDto(PaginationDto pagination) {
    final hasTitleFilter =
        pagination.title != null && pagination.title!.trim().isNotEmpty;
    final titleQuery = hasTitleFilter ? '%${pagination.title!.trim()}%' : null;
    final hasCategoryFilter = pagination.category != null;
    final category = pagination.category;
    // status가 null이거나 sold가 아니면 판매완료 제외
    final excludeSold = pagination.status == null;

    return ProductFilterParams(
      hasTitleFilter: hasTitleFilter,
      titleQuery: titleQuery,
      hasCategoryFilter: hasCategoryFilter,
      category: category,
      excludeSold: excludeSold,
    );
  }
}

/// Product 필터링 유틸리티
class ProductFilterUtil {
  /// 필터링 조건에 따른 where 절 생성
  static WhereExpressionBuilder<ProductTable>? buildWhereClause(
      ProductFilterParams params) {
    WhereExpressionBuilder<ProductTable>? baseWhere;

    // 제목 필터
    if (params.hasTitleFilter && params.hasCategoryFilter) {
      baseWhere = (p) =>
          p.title.like(params.titleQuery!) &
          p.category.equals(params.category!);
    } else if (params.hasTitleFilter) {
      baseWhere = (p) => p.title.like(params.titleQuery!);
    } else if (params.hasCategoryFilter) {
      baseWhere = (p) => p.category.equals(params.category!);
    }

    // 판매완료 제외 필터 (DB WHERE 절로 최적화)
    // status가 sold가 아닌 것만 (null, selling, reserved)
    if (params.excludeSold) {
      // ignore: prefer_function_declarations_over_variables
      final excludeSoldWhere = (ProductTable p) =>
          p.status.notEquals(ProductStatus.sold);

      if (baseWhere != null) {
        // 기존 조건과 AND 결합
        final previousWhere = baseWhere;
        baseWhere = (p) => previousWhere(p) & excludeSoldWhere(p);
      } else {
        // 판매완료 제외 조건만
        baseWhere = excludeSoldWhere;
      }
    }

    return baseWhere;
  }
}

/// Product 정렬 유틸리티
class ProductSortUtil {
  /// 정렬 기준에 따른 orderBy와 orderDescending 반환
  static (OrderByBuilder<ProductTable>, bool) getOrderByAndDescending(
      ProductSortBy sortBy) {
    switch (sortBy) {
      case ProductSortBy.latest:
        return ((p) => p.updatedAt, true);
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
