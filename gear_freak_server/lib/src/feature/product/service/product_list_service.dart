import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

import 'package:gear_freak_server/src/feature/product/util/product_filter_util.dart';

/// 상품 목록 서비스
/// 상품 목록 조회 및 통계 관련 비즈니스 로직을 처리합니다.
class ProductListService {
  // ==================== Public Methods ====================

  /// 페이지네이션된 상품 목록 조회
  ///
  /// 필터링, 정렬, 페이지네이션을 적용하여 상품 목록을 조회합니다.
  ///
  /// [session]: Serverpod 세션
  /// [pagination]: 페이지네이션 정보 (페이지, 개수, 정렬, 필터 포함)
  /// Returns: 페이지네이션된 상품 목록
  Future<PaginatedProductsResponseDto> getPaginatedProducts(
    Session session,
    PaginationDto pagination,
  ) async {
    final offset = (pagination.page - 1) * pagination.limit;
    final sortBy = pagination.sortBy ?? ProductSortBy.latest;
    final filterParams = ProductFilterParams.fromPaginationDto(pagination);

    // DB WHERE 절에서 모든 필터링 처리 (excludeSold 포함)
    final totalCount = await _getTotalCount(session, filterParams);
    final products = await _getSortedProducts(
        session, filterParams, sortBy, pagination.limit, offset);

    return _buildPaginationResponse(products, totalCount, pagination);
  }

  /// 내가 등록한 상품 목록 조회 (페이지네이션)
  ///
  /// 수정일 기준 최근순으로 정렬됩니다.
  /// [pagination.status]가 null이면 모든 상태의 상품을 반환합니다.
  /// [pagination.status]가 selling이면 판매중/예약중 상품을 반환합니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 판매자 ID
  /// [pagination]: 페이지네이션 정보 (상태 필터 포함)
  /// Returns: 페이지네이션된 상품 목록
  Future<PaginatedProductsResponseDto> getMyProducts(
    Session session,
    int userId,
    PaginationDto pagination,
  ) async {
    final offset = (pagination.page - 1) * pagination.limit;

    if (pagination.status != null) {
      if (pagination.status == ProductStatus.selling) {
        // 판매중인 경우: status가 null, selling, reserved인 상품 포함
        final allProducts = await Product.db.find(
          session,
          where: (p) => p.sellerId.equals(userId),
          orderBy: (p) => p.updatedAt,
          orderDescending: true,
        );

        final sellingProducts = _filterSellingProducts(allProducts);
        final paginatedProducts =
            _applyPagination(sellingProducts, offset, pagination.limit);

        return _buildPaginationResponse(
          paginatedProducts,
          sellingProducts.length,
          pagination,
        );
      } else {
        // 다른 상태인 경우: 해당 상태만
        final totalCount = await Product.db.count(
          session,
          where: (p) =>
              p.sellerId.equals(userId) & p.status.equals(pagination.status!),
        );

        final products = await Product.db.find(
          session,
          where: (p) =>
              p.sellerId.equals(userId) & p.status.equals(pagination.status!),
          orderBy: (p) => p.updatedAt,
          orderDescending: true,
          limit: pagination.limit,
          offset: offset,
        );

        return _buildPaginationResponse(products, totalCount, pagination);
      }
    }

    // status 필터링이 없는 경우 (모든 상태)
    final totalCount = await Product.db.count(
      session,
      where: (p) => p.sellerId.equals(userId),
    );

    final products = await Product.db.find(
      session,
      where: (p) => p.sellerId.equals(userId),
      orderBy: (p) => p.updatedAt,
      orderDescending: true,
      limit: pagination.limit,
      offset: offset,
    );

    return _buildPaginationResponse(products, totalCount, pagination);
  }

  /// 내가 관심목록에 추가한 상품 목록 조회 (페이지네이션)
  ///
  /// 찜한 날짜 기준 최근순으로 정렬됩니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 사용자 ID
  /// [pagination]: 페이지네이션 정보
  /// Returns: 페이지네이션된 상품 목록
  Future<PaginatedProductsResponseDto> getMyFavoriteProducts(
    Session session,
    int userId,
    PaginationDto pagination,
  ) async {
    final offset = (pagination.page - 1) * pagination.limit;

    // Favorite 테이블에서 userId로 필터링하여 productId 목록 가져오기
    // 찜한 날 기준 최근순 정렬 (Favorite.createdAt DESC)
    final favorites = await Favorite.db.find(
      session,
      where: (f) => f.userId.equals(userId),
      orderBy: (f) => f.createdAt,
      orderDescending: true,
    );

    if (favorites.isEmpty) {
      return _buildPaginationResponse([], 0, pagination);
    }

    final totalCount = favorites.length;
    final paginatedFavorites =
        _applyPagination(favorites, offset, pagination.limit);

    // productId 목록으로 상품 조회 (N+1 쿼리 방지: IN 쿼리 사용)
    // 1. productId 목록 추출
    final productIds = paginatedFavorites
        .map((f) => f.productId)
        .toSet(); // Set으로 변환하여 중복 제거

    // 2. IN 쿼리로 한 번에 조회
    final allProducts = await Product.db.find(
      session,
      where: (p) => p.id.inSet(productIds),
    );

    // 3. 순서 유지 (찜한 순서) - Map으로 O(1) 조회
    final productMap = {for (var p in allProducts) p.id!: p};
    final products = paginatedFavorites
        .map((f) => productMap[f.productId])
        .whereType<Product>() // null 제거
        .toList();

    return _buildPaginationResponse(products, totalCount, pagination);
  }

  /// 상품 통계 조회
  ///
  /// 사용자의 판매중, 거래완료, 관심목록 개수, 후기 개수를 조회합니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 사용자 ID
  /// Returns: 상품 통계 DTO
  Future<ProductStatsDto> getProductStats(
    Session session,
    int userId,
  ) async {
    // 전체 상품 개수
    final totalCount = await Product.db.count(
      session,
      where: (p) => p.sellerId.equals(userId),
    );

    // 거래완료 상품 개수 (status = sold)
    final soldCount = await Product.db.count(
      session,
      where: (p) =>
          p.sellerId.equals(userId) & p.status.equals(ProductStatus.sold),
    );

    // 판매중 상품 개수 = 전체 - 거래완료
    // (status가 null, selling, reserved인 경우 모두 판매중으로 간주)
    final sellingCount = totalCount - soldCount;

    // 관심목록 상품 개수 (Favorite 테이블에서 userId로 카운트)
    final favoriteCount = await Favorite.db.count(
      session,
      where: (f) => f.userId.equals(userId),
    );

    // 후기 개수 (해당 사용자가 받은 모든 후기 - 구매자 후기 + 판매자 후기)
    final reviewCount = await TransactionReview.db.count(
      session,
      where: (review) => review.revieweeId.equals(userId),
    );

    return ProductStatsDto(
      sellingCount: sellingCount,
      soldCount: soldCount,
      favoriteCount: favoriteCount,
      reviewCount: reviewCount,
    );
  }

  // ==================== Private Helper Methods ====================

  /// 전체 개수 조회
  Future<int> _getTotalCount(
      Session session, ProductFilterParams params) async {
    final where = ProductFilterUtil.buildWhereClause(params);
    if (where != null) {
      return await Product.db.count(session, where: where);
    } else {
      return await Product.db.count(session);
    }
  }

  /// 정렬된 상품 조회
  Future<List<Product>> _getSortedProducts(
    Session session,
    ProductFilterParams params,
    ProductSortBy sortBy,
    int limit,
    int offset,
  ) async {
    final where = ProductFilterUtil.buildWhereClause(params);
    return await _findProductsWithSort(session,
        where: where, sortBy: sortBy, limit: limit, offset: offset);
  }

  /// 정렬 옵션에 따른 상품 조회
  Future<List<Product>> _findProductsWithSort(
    Session session, {
    required WhereExpressionBuilder<ProductTable>? where,
    required ProductSortBy sortBy,
    required int limit,
    required int offset,
  }) async {
    final orderByAndDesc = ProductSortUtil.getOrderByAndDescending(sortBy);

    if (where != null) {
      return await Product.db.find(
        session,
        where: where,
        orderBy: orderByAndDesc.$1,
        orderDescending: orderByAndDesc.$2,
        limit: limit,
        offset: offset,
      );
    } else {
      return await Product.db.find(
        session,
        orderBy: orderByAndDesc.$1,
        orderDescending: orderByAndDesc.$2,
        limit: limit,
        offset: offset,
      );
    }
  }

  /// 페이지네이션 응답 생성
  PaginatedProductsResponseDto _buildPaginationResponse(
    List<Product> products,
    int totalCount,
    PaginationDto pagination,
  ) {
    final offset = (pagination.page - 1) * pagination.limit;
    final hasMore = offset + products.length < totalCount;

    return PaginatedProductsResponseDto(
      pagination: PaginationDto(
        page: pagination.page,
        limit: pagination.limit,
        totalCount: totalCount,
        hasMore: hasMore,
      ),
      products: products,
    );
  }

  /// 판매완료 제외 필터링 (status가 null, selling, reserved인 상품만)
  List<Product> _filterSoldProducts(List<Product> products) {
    return products
        .where((p) =>
            p.status == null ||
            p.status == ProductStatus.selling ||
            p.status == ProductStatus.reserved)
        .toList();
  }

  /// 판매중 필터링 (status가 null, selling, reserved인 상품만)
  List<Product> _filterSellingProducts(List<Product> products) {
    return _filterSoldProducts(products);
  }

  /// 페이지네이션 적용
  List<T> _applyPagination<T>(List<T> items, int offset, int limit) {
    final startIndex = offset.clamp(0, items.length);
    final endIndex = (offset + limit).clamp(0, items.length);
    return items.sublist(startIndex, endIndex);
  }
}

