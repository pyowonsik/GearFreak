import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 홈 Repository 인터페이스
abstract class HomeRepository {
  /// 최근 등록 상품 조회
  Future<List<pod.Product>> getRecentProducts();

  /// 상품 상세 조회
  Future<pod.Product> getProductDetail(int id);
}
