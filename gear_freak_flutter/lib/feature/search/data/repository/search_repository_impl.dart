import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/search/data/datasource/search_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/search/domain/repository/search_repository.dart';

/// 검색 Repository 구현
class SearchRepositoryImpl implements SearchRepository {
  /// SearchRepositoryImpl 생성자
  ///
  /// [remoteDataSource]는 검색 원격 데이터 소스입니다.
  const SearchRepositoryImpl(this.remoteDataSource);

  /// 검색 원격 데이터 소스
  final SearchRemoteDataSource remoteDataSource;

  @override
  Future<pod.PaginatedProductsResponseDto> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    pod.ProductSortBy? sortBy,
  }) async {
    return remoteDataSource.searchProducts(
      query: query,
      page: page,
      limit: limit,
      sortBy: sortBy,
    );
  }
}
