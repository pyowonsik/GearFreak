import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../home/domain/entity/product.dart';
import '../../domain/entity/search_result.dart';
import '../../domain/repository/search_repository.dart';
import '../datasource/search_remote_datasource.dart';

/// 검색 Repository 구현
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  const SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<SearchResult> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final data = await remoteDataSource.searchProducts(
      query: query,
      page: page,
      limit: limit,
    );

    final products = data.map((item) {
      final categoryString = item['category'] as String? ?? 'equipment';
      final category = pod.ProductCategory.values.firstWhere(
        (e) => e.name == categoryString,
        orElse: () => pod.ProductCategory.equipment,
      );

      return Product(
        id: item['id'] as String,
        title: item['title'] as String,
        price: item['price'] as int,
        location: item['location'] as String,
        createdAt: DateTime.parse(item['createdAt'] as String),
        favoriteCount: item['favoriteCount'] as int,
        category: category,
      );
    }).toList();

    return SearchResult(
      products: products,
      totalCount: products.length,
      query: query,
    );
  }
}
