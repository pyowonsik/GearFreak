import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class ProductService {
  Future<Product> getProductById(Session session, int id) async {
    final product = await Product.db.findById(session, id);

    if (product == null) {
      throw Exception('Product not found');
    }

    return product;
  }

  /// 페이지네이션된 상품 목록 조회
  Future<PaginatedProductsResponseDto> getPaginatedProducts(
    Session session,
    PaginationDto pagination,
  ) async {
    // offset 계산 (page는 1부터 시작)
    final offset = (pagination.page - 1) * pagination.limit;

    // title 필터링 조건
    final hasTitleFilter =
        pagination.title != null && pagination.title!.trim().isNotEmpty;
    final titleQuery = hasTitleFilter ? '%${pagination.title!.trim()}%' : null;

    // 랜덤 정렬 여부
    final isRandom = pagination.random == true;

    // 전체 개수 조회 (title 필터링 적용)
    final totalCount = hasTitleFilter
        ? await Product.db.count(
            session,
            where: (p) => p.title.like(titleQuery!),
          )
        : await Product.db.count(
            session,
          );

    // 페이지네이션된 상품 목록 조회
    List<Product> products;

    if (isRandom) {
      // 랜덤 정렬: 모든 상품을 가져온 후 랜덤으로 선택
      final allProducts = hasTitleFilter
          ? await Product.db.find(
              session,
              where: (p) => p.title.like(titleQuery!),
            )
          : await Product.db.find(session);

      // 랜덤으로 섞기
      allProducts.shuffle();

      // 페이지네이션 적용
      final startIndex = offset;
      final endIndex = (offset + pagination.limit).clamp(0, allProducts.length);
      products = allProducts.sublist(
        startIndex.clamp(0, allProducts.length),
        endIndex,
      );
    } else {
      // 기본 정렬: createdAt 내림차순
      products = hasTitleFilter
          ? await Product.db.find(
              session,
              where: (p) => p.title.like(titleQuery!),
              orderBy: (p) => p.createdAt,
              orderDescending: true,
              limit: pagination.limit,
              offset: offset,
            )
          : await Product.db.find(
              session,
              orderBy: (p) => p.createdAt,
              orderDescending: true,
              limit: pagination.limit,
              offset: offset,
            );
    }

    // hasMore 계산
    final hasMore = offset + products.length < totalCount;

    print(
        '📊 [ProductService] 페이지네이션 조회: page=${pagination.page}, limit=${pagination.limit}, offset=$offset, title=${pagination.title ?? "없음"}, random=$isRandom');
    print(
        '📊 [ProductService] 결과: totalCount=$totalCount, 조회된 상품=${products.length}개, hasMore=$hasMore');

    // PaginationDto 생성 (응답용, title과 random은 제외)
    final responsePagination = PaginationDto(
      page: pagination.page,
      limit: pagination.limit,
      totalCount: totalCount,
      hasMore: hasMore,
    );

    return PaginatedProductsResponseDto(
      pagination: responsePagination,
      products: products,
    );
  }

  // Future<bool> deleteProduct(Session session, int id) async {
  //   final product = await Product.db.findById(session, id);
  //   if (product == null) {
  //     throw Exception('Product not found');
  //   }
  //   await Product.db.deleteRow(session, product);
  //   return true;
  // }
}
