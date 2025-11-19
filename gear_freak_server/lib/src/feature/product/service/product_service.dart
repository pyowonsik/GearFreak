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

    // 전체 개수 조회
    final totalCount = await Product.db.count(
      session,
    );

    // 페이지네이션된 상품 목록 조회
    final products = await Product.db.find(
      session,
      orderBy: (p) => p.createdAt,
      orderDescending: true,
      limit: pagination.limit,
      offset: offset,
    );

    // hasMore 계산
    final hasMore = offset + products.length < totalCount;

    print(
        '📊 [ProductService] 페이지네이션 조회: page=${pagination.page}, limit=${pagination.limit}, offset=$offset');
    print(
        '📊 [ProductService] 결과: totalCount=$totalCount, 조회된 상품=${products.length}개, hasMore=$hasMore');

    // PaginationDto 생성 (응답용)
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
