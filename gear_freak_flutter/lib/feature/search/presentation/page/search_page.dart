import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/core/util/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/search/di/search_providers.dart';
import 'package:gear_freak_flutter/feature/search/presentation/presentation.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';

/// 검색 화면
class SearchPage extends ConsumerStatefulWidget {
  /// SearchPage 생성자
  ///
  /// [key]는 위젯의 키입니다.
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
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
      screenName: 'SearchPage',
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
      appBar: const GbAppBar(
        title: Text('검색'),
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
                  ? SearchRecentSearchesWidget(
                      searchController: _searchController,
                      searchFocusNode: _searchFocusNode,
                    )
                  : switch (searchState) {
                      SearchInitial() => const SearchInitialView(),
                      SearchLoading() => const GbLoadingView(),
                      SearchError(:final message, :final query) => GbErrorView(
                          message: '에러: $message',
                          onRetry: () {
                            if (query != null) {
                              ref
                                  .read(searchNotifierProvider.notifier)
                                  .searchProducts(query);
                            }
                          },
                        ),
                      SearchLoaded(
                        :final result,
                        :final query,
                        :final sortBy
                      ) ||
                      SearchLoadingMore(
                        :final result,
                        :final query,
                        :final sortBy
                      ) =>
                        SearchLoadedView(
                          key: const ValueKey('search_loaded'),
                          products: result.products,
                          pagination: result.pagination,
                          query: query,
                          sortBy: sortBy,
                          scrollController: scrollController!,
                          isLoadingMore: searchState is SearchLoadingMore,
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
                    },
            ),
          ],
        ),
      ),
    );
  }
}
