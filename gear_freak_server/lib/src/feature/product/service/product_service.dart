import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:gear_freak_server/src/feature/product/util/product_filter_util.dart';

class ProductService {
  /// 상품 생성
  Future<Product> createProduct(
    Session session,
    int sellerId,
    CreateProductRequestDto request,
  ) async {
    final now = DateTime.now().toUtc();

    final product = Product(
      sellerId: sellerId,
      title: request.title,
      category: request.category,
      price: request.price,
      condition: request.condition,
      description: request.description,
      tradeMethod: request.tradeMethod,
      baseAddress: request.baseAddress,
      detailAddress: request.detailAddress,
      imageUrls: request.imageUrls,
      viewCount: 0,
      favoriteCount: 0,
      chatCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    return await Product.db.insertRow(session, product);
  }

  // 상품 조회
  Future<Product> getProductById(Session session, int id) async {
    final product = await Product.db.findById(session, id);

    if (product == null) {
      throw Exception('Product not found');
    }

    return product;
  }

  /// 찜 추가/제거 (토글)
  /// 반환값: true = 찜 추가됨, false = 찜 제거됨
  Future<bool> toggleFavorite(
      Session session, int userId, int productId) async {
    // 상품 존재 확인
    final product = await Product.db.findById(session, productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // 기존 찜 확인
    final existingFavorite = await Favorite.db.findFirstRow(
      session,
      where: (f) => f.userId.equals(userId) & f.productId.equals(productId),
    );

    if (existingFavorite != null) {
      // 찜 제거
      await Favorite.db.deleteRow(session, existingFavorite);

      // favoriteCount 감소
      final currentCount = product.favoriteCount ?? 0;
      final newCount = (currentCount - 1).clamp(0, double.infinity).toInt();
      await Product.db.updateRow(
        session,
        product.copyWith(favoriteCount: newCount),
        columns: (t) => [t.favoriteCount],
      );

      return false; // 찜 제거됨
    } else {
      // 찜 추가
      final favorite = Favorite(
        userId: userId,
        productId: productId,
        createdAt: DateTime.now(),
      );
      await Favorite.db.insertRow(session, favorite);

      // favoriteCount 증가
      final currentCount = product.favoriteCount ?? 0;
      await Product.db.updateRow(
        session,
        product.copyWith(favoriteCount: currentCount + 1),
        columns: (t) => [t.favoriteCount],
      );

      return true; // 찜 추가됨
    }
  }

  /// 찜 상태 조회
  Future<bool> isFavorite(Session session, int userId, int productId) async {
    final favorite = await Favorite.db.findFirstRow(
      session,
      where: (f) => f.userId.equals(userId) & f.productId.equals(productId),
    );
    return favorite != null;
  }

  /// 페이지네이션된 상품 목록 조회
  Future<PaginatedProductsResponseDto> getPaginatedProducts(
    Session session,
    PaginationDto pagination,
  ) async {
    final offset = (pagination.page - 1) * pagination.limit;
    final sortBy = pagination.sortBy ?? ProductSortBy.latest;
    final isRandom = pagination.random == true;

    // 필터링 조건 준비
    final filterParams = ProductFilterParams.fromPaginationDto(pagination);

    // 전체 개수 조회
    final totalCount = await _getTotalCount(session, filterParams);

    // 상품 목록 조회
    final products = isRandom
        ? await _getRandomProducts(
            session, filterParams, pagination.limit, offset)
        : await _getSortedProducts(
            session, filterParams, sortBy, pagination.limit, offset);

    // hasMore 계산
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

  /// 랜덤 정렬된 상품 조회
  Future<List<Product>> _getRandomProducts(
    Session session,
    ProductFilterParams params,
    int limit,
    int offset,
  ) async {
    // 필터링된 모든 상품 조회
    final allProducts = await _findProductsWithFilter(session, params);

    // 랜덤으로 섞기
    allProducts.shuffle();

    // 페이지네이션 적용
    final startIndex = offset.clamp(0, allProducts.length);
    final endIndex = (offset + limit).clamp(0, allProducts.length);
    return allProducts.sublist(startIndex, endIndex);
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

  /// 필터링된 상품 조회 (정렬 없음)
  Future<List<Product>> _findProductsWithFilter(
    Session session,
    ProductFilterParams params,
  ) async {
    final where = ProductFilterUtil.buildWhereClause(params);
    if (where != null) {
      return await Product.db.find(session, where: where);
    } else {
      return await Product.db.find(session);
    }
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
}
