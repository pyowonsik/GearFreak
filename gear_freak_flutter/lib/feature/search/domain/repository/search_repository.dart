import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 검색 Repository 인터페이스
// ignore: one_member_abstracts
abstract class SearchRepository {
  /// 상품 검색
  Future<pod.PaginatedProductsResponseDto> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    pod.ProductSortBy? sortBy,
  });
}
