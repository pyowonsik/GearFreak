import '../entity/search_result.dart';

/// 검색 Repository 인터페이스
abstract class SearchRepository {
  /// 상품 검색
  Future<SearchResult> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  });
}

