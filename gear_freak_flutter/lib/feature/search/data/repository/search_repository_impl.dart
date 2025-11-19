import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/repository/search_repository.dart';
import '../datasource/search_remote_datasource.dart';

/// 검색 Repository 구현
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  const SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<pod.PaginatedProductsResponseDto> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    return await remoteDataSource.searchProducts(
      query: query,
      page: page,
      limit: limit,
    );
  }
}
