import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 Repository 인터페이스
abstract class ProductRepository {
  /// 페이지네이션된 상품 목록 조회
  Future<pod.PaginatedProductsResponseDto> getPaginatedProducts(
    pod.PaginationDto pagination,
  );

  /// 상품 상세 조회
  Future<pod.Product> getProductDetail(int id);

  /// 찜 추가/제거 (토글)
  /// 반환값: true = 찜 추가됨, false = 찜 제거됨
  Future<bool> toggleFavorite(int productId);

  /// 찜 상태 조회
  Future<bool> isFavorite(int productId);

  /// 상품 생성
  Future<pod.Product> createProduct(pod.CreateProductRequestDto request);

  /// 상품 수정
  Future<pod.Product> updateProduct(pod.UpdateProductRequestDto request);

  /// 상품 삭제
  Future<void> deleteProduct(int productId);

  /// 내가 등록한 상품 목록 조회
  Future<pod.PaginatedProductsResponseDto> getMyProducts(
    pod.PaginationDto pagination,
  );

  /// 내가 관심목록한 상품 목록 조회
  Future<pod.PaginatedProductsResponseDto> getMyFavoriteProducts(
    pod.PaginationDto pagination,
  );
}
