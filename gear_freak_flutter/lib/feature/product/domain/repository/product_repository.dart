import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 Repository 인터페이스
abstract class ProductRepository {
  /// 페이지네이션된 상품 목록 조회
  Future<pod.PaginatedProductsResponseDto> getPaginatedProducts(
    pod.PaginationDto pagination,
  );

  /// 상품 상세 조회
  Future<pod.Product> getProductDetail(int id);
}

