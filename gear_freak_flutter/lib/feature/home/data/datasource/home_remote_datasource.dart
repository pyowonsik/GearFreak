import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/service/pod_service.dart';

/// 홈 원격 데이터 소스
class HomeRemoteDataSource {
  const HomeRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 최근 등록 상품 조회
  Future<List<Map<String, dynamic>>> getRecentProducts() async {
    // TODO: Serverpod 엔드포인트 호출
    // 임시 더미 데이터
    return List.generate(
        5,
        (index) => {
              'id': 'product_$index',
              'title': '상품 제목이 들어갑니다 ${index + 1}',
              'price': 150000 + (index * 10000),
              'location': '서울 강남구',
              'createdAt': DateTime.now()
                  .subtract(Duration(minutes: 5 + index))
                  .toIso8601String(),
              'favoriteCount': 12 + index,
              'category': pod.ProductCategory.equipment.name,
            });
  }

  /// 카테고리 목록 조회
  Future<List<pod.ProductCategory>> getCategories() async {
    // TODO: Serverpod 엔드포인트 호출
    return pod.ProductCategory.values;
  }
}
