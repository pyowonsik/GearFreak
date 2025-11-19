import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/service/pod_service.dart';

/// 검색 원격 데이터 소스
class SearchRemoteDataSource {
  const SearchRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 상품 검색
  Future<pod.PaginatedProductsResponseDto> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // getPaginatedProducts를 재사용하여 title로 필터링
      final pagination = pod.PaginationDto(
        page: page,
        limit: limit,
        title: query.trim().isNotEmpty ? query.trim() : null,
      );

      return await _client.product.getPaginatedProducts(pagination);
    } catch (e) {
      throw Exception('상품 검색에 실패했습니다: $e');
    }
  }
}
