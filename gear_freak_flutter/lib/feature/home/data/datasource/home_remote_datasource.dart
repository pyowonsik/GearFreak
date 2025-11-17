import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/service/pod_service.dart';

/// 홈 원격 데이터 소스
class HomeRemoteDataSource {
  const HomeRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 최근 등록 상품 조회
  Future<List<pod.Product>> getRecentProducts() async {
    try {
      return await _client.product.getProducts();
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
