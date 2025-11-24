import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/product_card_widget.dart';
import 'package:gear_freak_flutter/feature/search/di/search_providers.dart';
import 'package:gear_freak_flutter/feature/search/presentation/provider/search_state.dart';

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

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '리프팅 벨트, 보충제, 운동복을 검색해보세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(searchNotifierProvider.notifier)
                              .clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  ref
                      .read(searchNotifierProvider.notifier)
                      .searchProducts(value);
                }
              },
              onChanged: (value) {
                setState(() {}); // suffixIcon 업데이트를 위해
              },
            ),
          ),
          Expanded(
            child: _buildBody(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    return switch (state) {
      SearchInitial() => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                '상품을 검색해보세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      SearchLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
      SearchError(:final message, :final query) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '에러: $message',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (query != null) {
                    ref
                        .read(searchNotifierProvider.notifier)
                        .searchProducts(query);
                  }
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      SearchLoaded(:final result) => result.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: result.products.length +
                  (true == result.pagination.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == result.products.length) {
                  // 마지막에 로딩 인디케이터 표시
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final product = result.products[index];
                return ProductCardWidget(product: product);
              },
            ),
      SearchLoadingMore(:final result) => ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: result.products.length + 1,
          itemBuilder: (context, index) {
            if (index == result.products.length) {
              // 로딩 중 인디케이터 표시
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final product = result.products[index];
            return ProductCardWidget(product: product);
          },
        ),
    };
  }
}
