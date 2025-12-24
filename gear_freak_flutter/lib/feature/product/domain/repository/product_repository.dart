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

  /// 조회수 증가 (계정당 1회)
  /// 반환값: true = 조회수 증가됨, false = 이미 조회함 (증가 안 됨)
  Future<bool> incrementViewCount(int productId);

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

  /// 상품 상태 변경
  Future<pod.Product> updateProductStatus(
    pod.UpdateProductStatusRequestDto request,
  );

  /// 상품 통계 조회 (판매중, 거래완료, 관심목록 개수)
  Future<pod.ProductStatsDto> getProductStats();

  /// 다른 사용자의 상품 통계 조회 (판매중, 거래완료, 관심목록 개수, 후기 개수)
  /// [userId]는 조회할 사용자의 ID입니다.
  Future<pod.ProductStatsDto> getProductStatsByUserId(int userId);

  /// 다른 사용자의 상품 목록 조회 (페이지네이션)
  /// [userId]는 조회할 사용자의 ID입니다.
  Future<pod.PaginatedProductsResponseDto> getProductsByUserId(
    int userId,
    pod.PaginationDto pagination,
  );
}
