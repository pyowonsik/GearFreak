import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/domain.dart';
import 'search_state.dart';

/// 검색 Notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchProductsUseCase searchProductsUseCase;

  SearchNotifier(this.searchProductsUseCase) : super(const SearchInitial());

  /// 상품 검색 (첫 페이지)
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchInitial();
      return;
    }

    state = SearchLoading(query);

    print('🔄 [SearchNotifier] 검색 요청: query="$query", page=1, limit=20');
    final result = await searchProductsUseCase(
      SearchProductsParams(query: query, page: 1, limit: 20),
    );

    result.fold(
      (failure) {
        print('❌ [SearchNotifier] 검색 실패: ${failure.message}');
        state = SearchError(failure.message, query: query);
      },
      (searchResult) {
        print(
            '✅ [SearchNotifier] 검색 성공: query="$query", page=${searchResult.pagination.page}, totalCount=${searchResult.pagination.totalCount}, hasMore=${searchResult.pagination.hasMore}, products=${searchResult.products.length}개');
        state = SearchLoaded(
          result: searchResult,
          query: query,
        );
      },
    );
  }

  /// 검색 결과 더 불러오기
  Future<void> loadMoreProducts() async {
    final currentState = state;
    if (currentState is! SearchLoaded) {
      print(
          '⚠️ [SearchNotifier] loadMoreProducts: 현재 상태가 SearchLoaded가 아닙니다. (${currentState.runtimeType})');
      return;
    }

    final currentResult = currentState.result;
    final pagination = currentResult.pagination;

    // 더 불러올 데이터가 없으면 리턴
    if (pagination.hasMore != true) {
      print('⚠️ [SearchNotifier] loadMoreProducts: 더 이상 불러올 데이터가 없습니다.');
      return;
    }

    // 이미 로딩 중이면 리턴
    if (state is SearchLoadingMore) {
      print('⚠️ [SearchNotifier] loadMoreProducts: 이미 로딩 중입니다.');
      return;
    }

    // 다음 페이지 요청
    final nextPage = pagination.page + 1;
    print(
        '🔄 [SearchNotifier] 다음 페이지 로드: query="${currentState.query}", page=$nextPage (현재: ${pagination.page}, 전체: ${pagination.totalCount})');

    // 로딩 중 상태로 변경 (기존 데이터 유지)
    state = SearchLoadingMore(
      result: currentResult,
      query: currentState.query,
    );

    final result = await searchProductsUseCase(
      SearchProductsParams(
        query: currentState.query,
        page: nextPage,
        limit: 20,
      ),
    );

    result.fold(
      (failure) {
        print('❌ [SearchNotifier] 다음 페이지 로드 실패: ${failure.message}');
        // 에러 발생 시 이전 상태로 복구
        state = SearchLoaded(
          result: currentResult,
          query: currentState.query,
        );
      },
      (newResult) {
        // 기존 상품 목록에 새 상품 추가
        final updatedResult = pod.PaginatedProductsResponseDto(
          pagination: newResult.pagination,
          products: [
            ...currentResult.products,
            ...newResult.products,
          ],
        );

        print(
            '✅ [SearchNotifier] 다음 페이지 로드 성공: query="${currentState.query}", page=${newResult.pagination.page}, 추가된 상품=${newResult.products.length}개, 총 상품=${updatedResult.products.length}개, hasMore=${newResult.pagination.hasMore}');

        state = SearchLoaded(
          result: updatedResult,
          query: currentState.query,
        );
      },
    );
  }

  /// 검색 초기화
  void clearSearch() {
    state = const SearchInitial();
  }
}
