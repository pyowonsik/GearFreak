import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';

/// 검색 상태
class SearchState {
  final SearchResult? searchResult;
  final bool isLoading;
  final String? error;
  final String? currentQuery;

  const SearchState({
    this.searchResult,
    this.isLoading = false,
    this.error,
    this.currentQuery,
  });

  SearchState copyWith({
    SearchResult? searchResult,
    bool? isLoading,
    String? error,
    String? currentQuery,
  }) {
    return SearchState(
      searchResult: searchResult ?? this.searchResult,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

/// 검색 Notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchProductsUseCase searchProductsUseCase;

  SearchNotifier(this.searchProductsUseCase) : super(const SearchState());

  /// 상품 검색
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        searchResult: null,
        error: null,
        currentQuery: null,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentQuery: query,
    );

    final result = await searchProductsUseCase(
      SearchProductsParams(query: query),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (searchResult) {
        state = state.copyWith(
          searchResult: searchResult,
          isLoading: false,
        );
      },
    );
  }

  /// 검색 초기화
  void clearSearch() {
    state = const SearchState();
  }
}
