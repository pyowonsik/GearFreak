import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 검색 상태 (Sealed Class 방식)
sealed class SearchState {
  const SearchState();
}

/// 초기 상태
class SearchInitial extends SearchState {
  /// SearchInitial 생성자
  ///
  /// [recentSearches]는 최근 검색어 목록입니다.
  const SearchInitial({this.recentSearches = const []});

  /// 최근 검색어 목록
  final List<String> recentSearches;
}

/// 검색 중 상태
class SearchLoading extends SearchState {
  /// SearchLoading 생성자
  ///
  /// [query]는 검색 쿼리입니다.
  const SearchLoading(this.query);

  /// 검색 쿼리
  final String query;
}

/// 검색 결과 로드 성공 상태
class SearchLoaded extends SearchState {
  /// SearchLoaded 생성자
  ///
  /// [result]는 검색 결과입니다.
  /// [query]는 검색 쿼리입니다.
  /// [sortBy]는 정렬 기준입니다.
  const SearchLoaded({
    required this.result,
    required this.query,
    this.sortBy,
  });

  /// 검색 결과
  final pod.PaginatedProductsResponseDto result;

  /// 검색 쿼리
  final String query;

  /// 정렬 기준
  final pod.ProductSortBy? sortBy;
}

/// 검색 추가 로딩 중 상태 (기존 데이터 유지)
class SearchLoadingMore extends SearchState {
  /// SearchLoadingMore 생성자
  ///
  /// [result]는 검색 결과입니다.
  /// [query]는 검색 쿼리입니다.
  /// [sortBy]는 정렬 기준입니다.
  const SearchLoadingMore({
    required this.result,
    required this.query,
    this.sortBy,
  });

  /// 검색 결과
  final pod.PaginatedProductsResponseDto result;

  /// 검색 쿼리
  final String query;

  /// 정렬 기준
  final pod.ProductSortBy? sortBy;
}

/// 검색 실패 상태
class SearchError extends SearchState {
  /// SearchError 생성자
  ///
  /// [message]는 에러 메시지입니다.
  /// [query]는 검색 쿼리입니다.
  const SearchError(this.message, {this.query});

  /// 에러 메시지
  final String message;

  /// 검색 쿼리
  final String? query;
}
