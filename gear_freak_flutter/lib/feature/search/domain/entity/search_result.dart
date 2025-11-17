import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 검색 결과
class SearchResult {
  final List<pod.Product> products;
  final int totalCount;
  final String query;

  const SearchResult({
    required this.products,
    required this.totalCount,
    required this.query,
  });
}
