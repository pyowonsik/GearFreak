import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/service/pod_service.dart';

/// 검색 원격 데이터 소스
class SearchRemoteDataSource {
  const SearchRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 상품 검색
  Future<List<pod.Product>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // TODO: Serverpod 엔드포인트 호출
      // 예시: return await _client.product.searchProducts(query: query, page: page, limit: limit);
      
      // 임시로 모든 상품을 가져와서 필터링 (나중에 서버에서 검색 기능 구현 필요)
      final allProducts = await _client.product.getProducts();
      
      // 클라이언트 측에서 제목으로 필터링 (임시)
      final filteredProducts = allProducts
          .where((product) => product.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      return filteredProducts;
    } catch (e) {
      throw Exception('상품 검색에 실패했습니다: $e');
    }
  }
}
