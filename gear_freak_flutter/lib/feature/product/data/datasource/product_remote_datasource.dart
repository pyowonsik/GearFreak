import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/service/pod_service.dart';

/// 상품 원격 데이터 소스
class ProductRemoteDataSource {
  const ProductRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 최근 등록 상품 조회 (5개)
  Future<List<pod.Product>> getRecentProducts() async {
    try {
      return await _client.product.getRecentProducts();
    } catch (e) {
      throw Exception('최근 상품 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 전체 상품 조회
  Future<List<pod.Product>> getAllProducts() async {
    try {
      return await _client.product.getAllProducts();
    } catch (e) {
      throw Exception('상품 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 상품 상세 조회
  Future<pod.Product> getProductDetail(int id) async {
    try {
      return await _client.product.getProduct(id);
    } catch (e) {
      throw Exception('상품 상세를 불러오는데 실패했습니다: $e');
    }
  }
}
