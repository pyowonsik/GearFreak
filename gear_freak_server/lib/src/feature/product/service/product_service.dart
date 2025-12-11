import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:gear_freak_server/src/feature/product/util/product_filter_util.dart';
import 'package:gear_freak_server/src/common/s3/service/s3_service.dart';
import 'package:gear_freak_server/src/common/s3/util/s3_util.dart';

class ProductService {
  // ==================== Public Methods (Endpoint에서 직접 호출) ====================

  /// 상품 생성
  Future<Product> createProduct(
    Session session,
    int sellerId,
    CreateProductRequestDto request,
  ) async {
    final now = DateTime.now().toUtc();

    // 1. 상품 먼저 생성하여 productId 획득
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
      imageUrls: request.imageUrls, // 임시로 원본 URL 저장
      status: ProductStatus.selling, // 기본값: 판매중
      viewCount: 0,
      favoriteCount: 0,
      chatCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    final createdProduct = await Product.db.insertRow(session, product);
    final productId = createdProduct.id!;

    // 2. 이미지 파일들을 temp에서 실제 경로로 이동
    if (request.imageUrls != null && request.imageUrls!.isNotEmpty) {
      final movedImageUrls = <String>[];

      for (final imageUrl in request.imageUrls!) {
        try {
          // URL에서 파일 키 추출
          final sourceKey = S3Util.extractKeyFromUrl(imageUrl);

          // temp 경로인지 확인
          if (sourceKey.startsWith('temp/product/')) {
            // temp/product/{userId}/{file} -> product/{productId}/{file}
            final destinationKey =
                S3Util.convertTempKeyToProductKey(sourceKey, productId);

            // S3에서 파일 이동
            final movedUrl = await S3Service.moveS3Object(
              session,
              sourceKey,
              destinationKey,
              'public', // 상품 이미지는 public 버킷
            );

            movedImageUrls.add(movedUrl);
          } else {
            // 이미 이동된 파일이거나 다른 경로면 그대로 사용
            movedImageUrls.add(imageUrl);
          }
        } catch (e) {
          session.log(
            'Failed to move image: $imageUrl - $e',
            level: LogLevel.warning,
          );
          // 이동 실패 시 원본 URL 유지
          movedImageUrls.add(imageUrl);
        }
      }

      // 3. 이동된 URL로 상품 업데이트
      if (movedImageUrls.isNotEmpty) {
        await Product.db.updateRow(
          session,
          createdProduct.copyWith(imageUrls: movedImageUrls),
          columns: (t) => [t.imageUrls],
        );
      }

      // 이동된 URL로 반환
      return createdProduct.copyWith(imageUrls: movedImageUrls);
    }

    return createdProduct;
  }

  /// 상품 수정
  Future<Product> updateProduct(
    Session session,
    int productId,
    int sellerId,
    UpdateProductRequestDto request,
  ) async {
    // 1. 기존 상품 조회
    final existingProduct = await Product.db.findById(session, productId);
    if (existingProduct == null) {
      throw Exception('Product not found');
    }

    // 2. 권한 확인 (판매자만 수정 가능)
    if (existingProduct.sellerId != sellerId) {
      throw Exception('Unauthorized: Only the seller can update this product');
    }

    final now = DateTime.now().toUtc();
    final originalImageUrls = existingProduct.imageUrls ?? [];
    final finalImageUrls = request.imageUrls ?? [];

    // 3. 삭제할 이미지 식별 (원본에 있지만 최종 목록에 없는 것)
    final imagesToDelete = originalImageUrls
        .where((url) => !finalImageUrls.contains(url))
        .toList();

    // 4. 삭제할 이미지들을 S3에서 삭제
    for (final imageUrl in imagesToDelete) {
      try {
        final fileKey = S3Util.extractKeyFromUrl(imageUrl);
        // product 경로의 이미지만 삭제 (temp 경로는 나중에 이동 처리)
        if (fileKey.startsWith('product/')) {
          await S3Service.deleteS3Object(session, fileKey, 'public');
          session.log('Deleted image: $fileKey', level: LogLevel.info);
        }
      } catch (e) {
        session.log(
          'Failed to delete image: $imageUrl - $e',
          level: LogLevel.warning,
        );
        // 삭제 실패해도 계속 진행
      }
    }

    // 5. 새로 추가한 이미지 (temp 경로)를 product 경로로 이동
    final movedImageUrls = <String>[];
    for (final imageUrl in finalImageUrls) {
      try {
        final sourceKey = S3Util.extractKeyFromUrl(imageUrl);

        if (sourceKey.startsWith('temp/product/')) {
          // temp/product/{userId}/{file} -> product/{productId}/{file}
          final destinationKey =
              S3Util.convertTempKeyToProductKey(sourceKey, productId);

          // S3에서 파일 이동
          final movedUrl = await S3Service.moveS3Object(
            session,
            sourceKey,
            destinationKey,
            'public',
          );

          movedImageUrls.add(movedUrl);
        } else {
          // 이미 product 경로에 있거나 다른 경로면 그대로 사용
          movedImageUrls.add(imageUrl);
        }
      } catch (e) {
        session.log(
          'Failed to move image: $imageUrl - $e',
          level: LogLevel.warning,
        );
        // 이동 실패 시 원본 URL 유지
        movedImageUrls.add(imageUrl);
      }
    }

    // 6. 상품 정보 업데이트
    final updatedProduct = existingProduct.copyWith(
      title: request.title,
      category: request.category,
      price: request.price,
      condition: request.condition,
      description: request.description,
      tradeMethod: request.tradeMethod,
      baseAddress: request.baseAddress,
      detailAddress: request.detailAddress,
      imageUrls: movedImageUrls.isEmpty ? null : movedImageUrls,
      updatedAt: now,
    );

    final result = await Product.db.updateRow(
      session,
      updatedProduct,
      columns: (t) => [
        t.title,
        t.category,
        t.price,
        t.condition,
        t.description,
        t.tradeMethod,
        t.baseAddress,
        t.detailAddress,
        t.imageUrls,
        t.updatedAt,
      ],
    );

    return result;
  }

  /// 상품 조회
  Future<Product> getProductById(Session session, int id) async {
    final product = await Product.db.findById(session, id);

    if (product == null) {
      throw Exception('Product not found');
    }

    return product;
  }

  /// 상품 상태 변경
  Future<Product> updateProductStatus(
    Session session,
    int productId,
    int userId,
    ProductStatus status,
  ) async {
    // 1. 기존 상품 조회
    final product = await Product.db.findById(session, productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // 2. 권한 확인 (판매자만 상태 변경 가능)
    if (product.sellerId != userId) {
      throw Exception(
        'Unauthorized: Only the seller can update product status',
      );
    }

    // 3. 상태 업데이트
    final now = DateTime.now().toUtc();
    final updatedProduct = product.copyWith(
      status: status,
      updatedAt: now,
    );

    final result = await Product.db.updateRow(
      session,
      updatedProduct,
      columns: (t) => [
        t.status,
        t.updatedAt,
      ],
    );

    return result;
  }

  /// 상품 삭제
  Future<void> deleteProduct(
    Session session,
    int productId,
    int userId,
  ) async {
    // 1. 기존 상품 조회
    final product = await Product.db.findById(session, productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // 2. 권한 확인 (판매자만 삭제 가능)
    if (product.sellerId != userId) {
      throw Exception('Unauthorized: Only the seller can delete this product');
    }

    // 3. 상품 이미지들을 S3에서 삭제
    if (product.imageUrls != null && product.imageUrls!.isNotEmpty) {
      for (final imageUrl in product.imageUrls!) {
        try {
          final fileKey = S3Util.extractKeyFromUrl(imageUrl);
          // product 경로의 이미지만 삭제
          if (fileKey.startsWith('product/')) {
            await S3Service.deleteS3Object(session, fileKey, 'public');
            session.log('Deleted image: $fileKey', level: LogLevel.info);
          }
        } catch (e) {
          session.log(
            'Failed to delete image: $imageUrl - $e',
            level: LogLevel.warning,
          );
          // 삭제 실패해도 계속 진행
        }
      }
    }

    // 4. 관련된 찜 데이터 삭제
    final favorites = await Favorite.db.find(
      session,
      where: (f) => f.productId.equals(productId),
    );

    for (final favorite in favorites) {
      await Favorite.db.deleteRow(session, favorite);
    }

    // 5. 상품 삭제
    await Product.db.deleteRow(session, product);
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
    final filterParams = ProductFilterParams.fromPaginationDto(pagination);

    // 판매완료 제외가 필요한 경우
    if (filterParams.excludeSold) {
      final allProducts = await _findProductsWithFilter(session, filterParams);
      final filteredProducts = _filterSoldProducts(allProducts);
      final sortedProducts = _sortProducts(filteredProducts, sortBy);
      final paginatedProducts =
          _applyPagination(sortedProducts, offset, pagination.limit);

      return _buildPaginationResponse(
        paginatedProducts,
        sortedProducts.length,
        pagination,
      );
    }

    // 일반적인 경우 (판매완료 제외 불필요)
    final totalCount = await _getTotalCount(session, filterParams);
    final products = await _getSortedProducts(
            session, filterParams, sortBy, pagination.limit, offset);

    return _buildPaginationResponse(products, totalCount, pagination);
  }

  /// 내가 등록한 상품 목록 조회 (페이지네이션)
  /// 등록일 기준 최근순으로 정렬됩니다.
  /// [pagination.status]가 null이면 모든 상태의 상품을 반환합니다.
  /// [pagination.status]가 null이 아니면 해당 상태의 상품만 반환합니다.
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
          orderBy: (p) => p.createdAt,
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
          orderBy: (p) => p.createdAt,
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
      orderBy: (p) => p.createdAt,
      orderDescending: true,
        limit: pagination.limit,
      offset: offset,
    );

    return _buildPaginationResponse(products, totalCount, pagination);
  }

  /// 내가 관심목록한 상품 목록 조회 (페이지네이션)
  /// 찜한 날 기준 최근순으로 정렬됩니다.
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

    // productId 목록으로 상품 조회 (찜한 순서 유지)
    final products = <Product>[];
    for (final favorite in paginatedFavorites) {
      final product = await Product.db.findById(session, favorite.productId);
      if (product != null) {
        products.add(product);
      }
    }

    return _buildPaginationResponse(products, totalCount, pagination);
  }

  /// 상품 통계 조회 (판매중, 거래완료, 관심목록 개수)
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

    // 예약 상품 개수 (status = reserved)
    final reservedCount = await Product.db.count(
      session,
      where: (p) =>
          p.sellerId.equals(userId) & p.status.equals(ProductStatus.reserved),
    );

    // 판매중 상품 개수 = 전체 - 거래완료 - 예약
    // (status가 null이거나 selling인 경우 모두 판매중으로 간주)
    final sellingCount = totalCount - soldCount - reservedCount;

    // 관심목록 상품 개수 (Favorite 테이블에서 userId로 카운트)
    final favoriteCount = await Favorite.db.count(
      session,
      where: (f) => f.userId.equals(userId),
    );

    return ProductStatsDto(
      sellingCount: sellingCount,
      soldCount: soldCount,
      favoriteCount: favoriteCount,
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

  /// 상품 목록 정렬
  List<Product> _sortProducts(
    List<Product> products,
    ProductSortBy sortBy,
  ) {
    final sorted = List<Product>.from(products);

    switch (sortBy) {
      case ProductSortBy.latest:
        sorted.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return bDate.compareTo(aDate); // 최신순 (내림차순)
        });
        break;
      case ProductSortBy.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortBy.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortBy.popular:
        sorted.sort((a, b) {
          final aCount = a.favoriteCount ?? 0;
          final bCount = b.favoriteCount ?? 0;
          return bCount.compareTo(aCount); // 인기순 (내림차순)
        });
        break;
    }

    return sorted;
  }

  /// 페이지네이션 적용
  List<T> _applyPagination<T>(List<T> items, int offset, int limit) {
    final startIndex = offset.clamp(0, items.length);
    final endIndex = (offset + limit).clamp(0, items.length);
    return items.sublist(startIndex, endIndex);
  }
}
