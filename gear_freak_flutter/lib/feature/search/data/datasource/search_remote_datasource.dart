import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/service/pod_service.dart';

/// 검색 원격 데이터 소스
class SearchRemoteDataSource {
  const SearchRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 상품 검색
  Future<List<Map<String, dynamic>>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    // TODO: Serverpod 엔드포인트 호출
    // 예시: return await client.search.searchProducts(query: query, page: page, limit: limit);

    // 임시 더미 데이터
    await Future.delayed(const Duration(milliseconds: 500));

    return List.generate(
      5,
      (index) => {
        'id': 'product_${query}_$index',
        'title': '$query 관련 상품 ${index + 1}',
        'price': 100000 + (index * 10000),
        'location': '서울 강남구',
        'createdAt': DateTime.now().toIso8601String(),
        'favoriteCount': 10 + index,
        'category': '검색결과',
      },
    );
  }
}
