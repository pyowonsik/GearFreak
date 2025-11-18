import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 Repository 인터페이스
abstract class ProductRepository {
  /// 최근 등록 상품 조회 (5개)
  Future<List<pod.Product>> getRecentProducts();

  /// 전체 상품 조회
  Future<List<pod.Product>> getAllProducts();

  /// 상품 상세 조회
  Future<pod.Product> getProductDetail(int id);
}

