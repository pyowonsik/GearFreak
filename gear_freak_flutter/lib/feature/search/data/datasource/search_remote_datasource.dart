import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';
import 'package:gear_freak_flutter/feature/product/data/datasource/product_remote_datasource.dart';

/// 검색 원격 데이터 소스
class SearchRemoteDataSource {
  /// SearchRemoteDataSource 생성자
  const SearchRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 🧪 Mock 데이터 사용 여부 (테스트용)
  static const bool _useMockData = true;

  /// 상품 검색
  Future<pod.PaginatedProductsResponseDto> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    pod.ProductSortBy? sortBy,
  }) async {
    if (_useMockData) {
      // ProductRemoteDataSource의 mock 데이터 재사용
      final productDataSource = ProductRemoteDataSource();
      final pagination = pod.PaginationDto(
        page: page,
        limit: limit,
        title: query.trim().isNotEmpty ? query.trim() : null,
        sortBy: sortBy,
      );
      return await productDataSource.getPaginatedProducts(pagination);
    }

    try {
      // getPaginatedProducts를 재사용하여 title로 필터링
      final pagination = pod.PaginationDto(
        page: page,
        limit: limit,
        title: query.trim().isNotEmpty ? query.trim() : null,
        sortBy: sortBy,
      );

      return await _client.product.getPaginatedProducts(pagination);
    } catch (e) {
      throw Exception('상품 검색에 실패했습니다: $e');
    }
  }
}
