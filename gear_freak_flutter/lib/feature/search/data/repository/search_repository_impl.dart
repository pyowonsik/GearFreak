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
    final products = await remoteDataSource.searchProducts(
      query: query,
      page: page,
      limit: limit,
    );

    return SearchResult(
      products: products,
      totalCount: products.length,
      query: query,
    );
  }
}
