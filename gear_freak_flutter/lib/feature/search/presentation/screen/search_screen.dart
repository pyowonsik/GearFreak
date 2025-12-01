import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/view/gb_error_view.dart';
import 'package:gear_freak_flutter/common/presentation/view/gb_loading_view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/search/di/search_providers.dart';
import 'package:gear_freak_flutter/feature/search/presentation/provider/search_state.dart';
import 'package:gear_freak_flutter/feature/search/presentation/view/search_initial_view.dart';
import 'package:gear_freak_flutter/feature/search/presentation/view/search_loaded_view.dart';
import 'package:gear_freak_flutter/feature/search/presentation/view/search_recent_searches_view.dart';
import 'package:gear_freak_flutter/feature/search/presentation/widget/search_text_field_widget.dart';

/// 검색 화면
class SearchScreen extends ConsumerStatefulWidget {
  /// SearchScreen 생성자
  ///
  /// [key]는 위젯의 키입니다.
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with PaginationScrollMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _showRecentSearches = false;

  @override
  void initState() {
    super.initState();
    // 포커스 상태 리스너 추가
    _searchFocusNode.addListener(() {
      setState(() {
        _showRecentSearches = _searchFocusNode.hasFocus;
      });
    });
    initPaginationScroll(
      onLoadMore: () {
        ref.read(searchNotifierProvider.notifier).loadMoreProducts();
      },
      getPagination: () {
        final searchState = ref.read(searchNotifierProvider);
        if (searchState is SearchLoaded) {
          return searchState.result.pagination;
        }
        return null;
      },
      isLoading: () {
        final searchState = ref.read(searchNotifierProvider);
        return searchState is SearchLoadingMore;
      },
      screenName: 'SearchScreen',
    );
  }

  @override
  void dispose() {
    disposePaginationScroll();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
      ),
      body: GestureDetector(
        onTap: () {
          // 키보드 내리기
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            SearchTextFieldWidget(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  final searchState = ref.read(searchNotifierProvider);
                  final currentSortBy =
                      searchState is SearchLoaded ? searchState.sortBy : null;
                  ref
                      .read(searchNotifierProvider.notifier)
                      .searchProducts(value, sortBy: currentSortBy);
                  _searchFocusNode.unfocus(); // 검색 시 포커스 해제
                }
              },
              onClear: () {
                _searchController.clear();
                ref.read(searchNotifierProvider.notifier).clearSearch();
              },
            ),
            Expanded(
              child: _showRecentSearches
                  ? _buildRecentSearchesScreen()
                  : _buildBody(searchState),
            ),
          ],
        ),
      ),
    );
  }

  /// 최근 검색어 화면 위젯
  Widget _buildRecentSearchesScreen() {
    final searchState = ref.watch(searchNotifierProvider);

    // SearchInitial 상태면 바로 사용, 아니면 FutureBuilder로 가져오기
    final recentSearches =
        searchState is SearchInitial ? searchState.recentSearches : null;

    return SearchRecentSearchesView(
      recentSearches: recentSearches,
      onSearchTap: (query) {
        // 검색어 입력
        _searchController.text = query;
        // 검색 실행
        ref.read(searchNotifierProvider.notifier).searchProducts(query);
        // 포커스 해제
        _searchFocusNode.unfocus();
      },
      onClearAll: () {
        ref.read(searchNotifierProvider.notifier).clearAllRecentSearches();
      },
      onDelete: (query) {
        ref.read(searchNotifierProvider.notifier).deleteRecentSearch(query);
      },
    );
  }

  Widget _buildBody(SearchState state) {
    return switch (state) {
      SearchInitial() => const SearchInitialView(),
      SearchLoading() => const GbLoadingView(),
      SearchError(:final message, :final query) => GbErrorView(
          message: '에러: $message',
          onRetry: () {
            if (query != null) {
              ref
                  .read(searchNotifierProvider.notifier)
                  .searchProducts(query, sortBy: null);
            }
          },
        ),
      SearchLoaded(:final result, :final query, :final sortBy) =>
        SearchLoadedView(
          key: const ValueKey('search_loaded'),
          products: result.products,
          pagination: result.pagination,
          query: query,
          sortBy: sortBy,
          scrollController: scrollController!,
          isLoadingMore: false,
          onSortChanged: (pod.ProductSortBy? newSortBy) async {
            await ref
                .read(searchNotifierProvider.notifier)
                .searchProducts(query, sortBy: newSortBy);
          },
          onRefresh: () async {
            await ref
                .read(searchNotifierProvider.notifier)
                .searchProducts(query, sortBy: sortBy);
          },
        ),
      SearchLoadingMore(:final result, :final query, :final sortBy) =>
        SearchLoadedView(
          key: const ValueKey('search_loaded'),
          products: result.products,
          pagination: result.pagination,
          query: query,
          sortBy: sortBy,
          scrollController: scrollController!,
          isLoadingMore: true,
          onSortChanged: (pod.ProductSortBy? newSortBy) async {
            await ref
                .read(searchNotifierProvider.notifier)
                .searchProducts(query, sortBy: newSortBy);
          },
          onRefresh: () async {
            await ref
                .read(searchNotifierProvider.notifier)
                .searchProducts(query, sortBy: sortBy);
          },
        ),
    };
  }
}
