import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/recent_search_service.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/search/domain/domain.dart';
import 'package:gear_freak_flutter/feature/search/presentation/provider/search_state.dart';

/// 검색 Notifier
class SearchNotifier extends StateNotifier<SearchState> {
  /// SearchNotifier 생성자
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// [searchProductsUseCase]는 상품 검색 UseCase 인스턴스입니다.
  SearchNotifier(
    this.ref,
    this.searchProductsUseCase,
  ) : super(const SearchInitial()) {
    // 초기화 시 최근 검색어 로드
    _loadRecentSearches();

    // 삭제 이벤트 감지하여 자동으로 목록에서 제거
    ref
      ..listen<int?>(deletedProductIdProvider, (previous, next) {
        if (next != null) {
          _removeProduct(next);
        }
      })

      // 수정 이벤트 감지하여 자동으로 목록에서 업데이트
      ..listen<pod.Product?>(updatedProductProvider, (previous, next) {
        if (next != null) {
          _updateProduct(next);
        }
      });
  }

  /// Riverpod Ref 인스턴스
  final Ref ref;

  /// 상품 검색 UseCase 인스턴스
  final SearchProductsUseCase searchProductsUseCase;

  /// 최근 검색어 서비스
  final RecentSearchService _recentSearchService = RecentSearchService();

  /// 최근 검색어 로드
  Future<void> _loadRecentSearches() async {
    final recentSearches = await _recentSearchService.getRecentSearches();
    if (state is SearchInitial) {
      state = SearchInitial(recentSearches: recentSearches);
    }
  }

  /// 최근 검색어 가져오기 (public)
  Future<List<String>> getRecentSearches() async {
    return await _recentSearchService.getRecentSearches();
  }

  /// 상품 검색 (첫 페이지)
  Future<void> searchProducts(String query, {pod.ProductSortBy? sortBy}) async {
    if (query.trim().isEmpty) {
      await _loadRecentSearches();
      return;
    }

    // 최근 검색어 저장
    await _recentSearchService.saveSearch(query);

    state = SearchLoading(query);

    debugPrint(
        '🔄 [SearchNotifier] 검색 요청: query="$query", page=1, limit=20, sortBy=$sortBy');
    final result = await searchProductsUseCase(
      SearchProductsParams(query: query, sortBy: sortBy),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [SearchNotifier] 검색 실패: ${failure.message}');
        state = SearchError(failure.message, query: query);
      },
      (searchResult) {
        debugPrint('✅ [SearchNotifier] 검색 성공: query="$query", '
            'page=${searchResult.pagination.page}, '
            'totalCount=${searchResult.pagination.totalCount}, '
            'hasMore=${searchResult.pagination.hasMore}, '
            'products=${searchResult.products.length}개');
        state = SearchLoaded(
          result: searchResult,
          query: query,
          sortBy: sortBy,
        );
      },
    );
  }

  /// 검색 결과 더 불러오기
  Future<void> loadMoreProducts() async {
    final currentState = state;
    if (currentState is! SearchLoaded) {
      debugPrint(
          '⚠️ [SearchNotifier] loadMoreProducts: 현재 상태가 SearchLoaded가 아닙니다. '
          '(${currentState.runtimeType})');
      return;
    }

    final currentResult = currentState.result;
    final pagination = currentResult.pagination;

    // 더 불러올 데이터가 없으면 리턴
    if (pagination.hasMore != true) {
      debugPrint('⚠️ [SearchNotifier] loadMoreProducts: 더 이상 불러올 데이터가 없습니다.');
      return;
    }

    // 이미 로딩 중이면 리턴
    if (state is SearchLoadingMore) {
      debugPrint('⚠️ [SearchNotifier] loadMoreProducts: 이미 로딩 중입니다.');
      return;
    }

    // 다음 페이지 요청
    final nextPage = pagination.page + 1;
    debugPrint('🔄 [SearchNotifier] 다음 페이지 로드: query="${currentState.query}", '
        'page=$nextPage (현재: ${pagination.page}, '
        '전체: ${pagination.totalCount})');

    // 로딩 중 상태로 변경 (기존 데이터 유지)
    state = SearchLoadingMore(
      result: currentResult,
      query: currentState.query,
      sortBy: currentState.sortBy,
    );

    final result = await searchProductsUseCase(
      SearchProductsParams(
        query: currentState.query,
        page: nextPage,
        sortBy: currentState.sortBy,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [SearchNotifier] 다음 페이지 로드 실패: ${failure.message}');
        // 에러 발생 시 이전 상태로 복구
        state = SearchLoaded(
          result: currentResult,
          query: currentState.query,
          sortBy: currentState.sortBy,
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

        debugPrint(
            '✅ [SearchNotifier] 다음 페이지 로드 성공: query="${currentState.query}", '
            'page=${newResult.pagination.page}, '
            '추가된 상품=${newResult.products.length}개, '
            '총 상품=${updatedResult.products.length}개, '
            'hasMore=${newResult.pagination.hasMore}');

        state = SearchLoaded(
          result: updatedResult,
          query: currentState.query,
          sortBy: currentState.sortBy,
        );
      },
    );
  }

  /// 검색 초기화
  Future<void> clearSearch() async {
    await _loadRecentSearches();
  }

  /// 특정 최근 검색어 삭제
  Future<void> deleteRecentSearch(String query) async {
    await _recentSearchService.deleteSearch(query);
    await _loadRecentSearches();
  }

  /// 모든 최근 검색어 삭제
  Future<void> clearAllRecentSearches() async {
    await _recentSearchService.clearAll();
    state = const SearchInitial(recentSearches: []);
  }

  /// 목록에서 상품 제거 (삭제 이벤트에 의해 자동 호출)
  void _removeProduct(int productId) {
    final currentState = state;
    if (currentState is SearchLoaded) {
      final updatedProducts = currentState.result.products
          .where((product) => product.id != productId)
          .toList();

      // 상품이 실제로 제거되었는지 확인
      if (updatedProducts.length < currentState.result.products.length) {
        debugPrint('🗑️ [SearchNotifier] 상품 제거: productId=$productId '
            '(${currentState.result.products.length}개 → ${updatedProducts.length}개)');

        // totalCount도 감소
        final updatedTotalCount =
            (currentState.result.pagination.totalCount ?? 0) - 1;

        // 업데이트된 결과 생성
        final updatedResult = pod.PaginatedProductsResponseDto(
          pagination: currentState.result.pagination.copyWith(
            totalCount: updatedTotalCount.clamp(0, double.infinity).toInt(),
            hasMore: updatedProducts.length < updatedTotalCount,
          ),
          products: updatedProducts,
        );

        state = SearchLoaded(
          result: updatedResult,
          query: currentState.query,
          sortBy: currentState.sortBy,
        );
      }
    } else if (currentState is SearchLoadingMore) {
      // 로딩 중 상태에서도 제거 처리
      final updatedProducts = currentState.result.products
          .where((product) => product.id != productId)
          .toList();

      if (updatedProducts.length < currentState.result.products.length) {
        debugPrint('🗑️ [SearchNotifier] 상품 제거 (로딩 중): productId=$productId');

        final updatedTotalCount =
            (currentState.result.pagination.totalCount ?? 0) - 1;

        final updatedResult = pod.PaginatedProductsResponseDto(
          pagination: currentState.result.pagination.copyWith(
            totalCount: updatedTotalCount.clamp(0, double.infinity).toInt(),
            hasMore: updatedProducts.length < updatedTotalCount,
          ),
          products: updatedProducts,
        );

        state = SearchLoadingMore(
          result: updatedResult,
          query: currentState.query,
          sortBy: currentState.sortBy,
        );
      }
    }
  }

  /// 목록에서 상품 수정 (수정 이벤트에 의해 자동 호출)
  void _updateProduct(pod.Product updatedProduct) {
    final currentState = state;

    if (currentState is SearchLoaded) {
      final updatedProducts = currentState.result.products.map((product) {
        // 같은 ID면 새 데이터로 교체
        return product.id == updatedProduct.id ? updatedProduct : product;
      }).toList();

      // 실제로 변경이 있었는지 확인
      final hasChanges =
          currentState.result.products.any((p) => p.id == updatedProduct.id);

      if (hasChanges) {
        debugPrint('✏️ [SearchNotifier] 상품 수정: productId=${updatedProduct.id}');

        final updatedResult = pod.PaginatedProductsResponseDto(
          pagination: currentState.result.pagination,
          products: updatedProducts,
        );

        state = SearchLoaded(
          result: updatedResult,
          query: currentState.query,
          sortBy: currentState.sortBy,
        );
      }
    } else if (currentState is SearchLoadingMore) {
      // 로딩 중 상태에서도 수정 처리
      final updatedProducts = currentState.result.products.map((product) {
        return product.id == updatedProduct.id ? updatedProduct : product;
      }).toList();

      final hasChanges =
          currentState.result.products.any((p) => p.id == updatedProduct.id);

      if (hasChanges) {
        debugPrint(
            '✏️ [SearchNotifier] 상품 수정 (로딩 중): productId=${updatedProduct.id}');

        final updatedResult = pod.PaginatedProductsResponseDto(
          pagination: currentState.result.pagination,
          products: updatedProducts,
        );

        state = SearchLoadingMore(
          result: updatedResult,
          query: currentState.query,
          sortBy: currentState.sortBy,
        );
      }
    }
  }
}
