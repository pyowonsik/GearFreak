import '../../../home/domain/entity/product.dart';

/// 검색 결과
class SearchResult {
  final List<Product> products;
  final int totalCount;
  final String query;

  const SearchResult({
    required this.products,
    required this.totalCount,
    required this.query,
  });
}

