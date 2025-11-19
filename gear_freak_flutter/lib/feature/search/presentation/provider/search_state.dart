import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 검색 상태 (Sealed Class 방식)
sealed class SearchState {
  const SearchState();
}

/// 초기 상태
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// 검색 중 상태
class SearchLoading extends SearchState {
  final String query;

  const SearchLoading(this.query);
}

/// 검색 결과 로드 성공 상태
class SearchLoaded extends SearchState {
  final pod.PaginatedProductsResponseDto result;
  final String query;

  const SearchLoaded({
    required this.result,
    required this.query,
  });
}

/// 검색 추가 로딩 중 상태 (기존 데이터 유지)
class SearchLoadingMore extends SearchState {
  final pod.PaginatedProductsResponseDto result;
  final String query;

  const SearchLoadingMore({
    required this.result,
    required this.query,
  });
}

/// 검색 실패 상태
class SearchError extends SearchState {
  final String message;
  final String? query;

  const SearchError(this.message, {this.query});
}
