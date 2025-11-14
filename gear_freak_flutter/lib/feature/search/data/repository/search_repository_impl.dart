import '../../../home/domain/entity/product.dart';
import '../../domain/entity/search_result.dart';
import '../../domain/repository/search_repository.dart';
import '../datasource/search_remote_datasource.dart';

/// 검색 Repository 구현
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

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

    final products = data.map((item) => Product(
      id: item['id'] as String,
      title: item['title'] as String,
      price: item['price'] as int,
      location: item['location'] as String,
      createdAt: DateTime.parse(item['createdAt'] as String),
      favoriteCount: item['favoriteCount'] as int,
      category: item['category'] as String,
    )).toList();

    return SearchResult(
      products: products,
      totalCount: products.length,
      query: query,
    );
  }
}

