import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
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

  /// 정렬 옵션 문자열을 ProductSortBy enum으로 변환
  pod.ProductSortBy? _getSortByFromString(String sortString) {
    switch (sortString) {
      case '최신순':
        return pod.ProductSortBy.latest;
      case '인기순':
        return pod.ProductSortBy.popular;
      case '낮은 가격순':
        return pod.ProductSortBy.priceAsc;
      case '높은 가격순':
        return pod.ProductSortBy.priceDesc;
      default:
        return null;
    }
  }

  /// ProductSortBy enum을 문자열로 변환
  String _getStringFromSortBy(pod.ProductSortBy? sortBy) {
    switch (sortBy) {
      case pod.ProductSortBy.latest:
        return '최신순';
      case pod.ProductSortBy.popular:
        return '인기순';
      case pod.ProductSortBy.priceAsc:
        return '낮은 가격순';
      case pod.ProductSortBy.priceDesc:
        return '높은 가격순';
      default:
        return '최신순';
    }
  }

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
                  final searchState = ref.read(searchNotifierProvider);
                  final currentSortBy =
                      searchState is SearchLoaded ? searchState.sortBy : null;
                  ref
                      .read(searchNotifierProvider.notifier)
                      .searchProducts(value, sortBy: currentSortBy);
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
                        .searchProducts(query, sortBy: null);
                  }
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      SearchLoaded(:final result, :final query, :final sortBy) => result
              .products.isEmpty
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
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(searchNotifierProvider.notifier)
                    .searchProducts(query, sortBy: sortBy);
              },
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 검색 결과 목록
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '전체 ${result.pagination.totalCount ?? 0}개',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              PopupMenuButton<String>(
                                initialValue: _getStringFromSortBy(sortBy),
                                onSelected: (value) async {
                                  final newSortBy = _getSortByFromString(value);
                                  await ref
                                      .read(searchNotifierProvider.notifier)
                                      .searchProducts(query, sortBy: newSortBy);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: '최신순',
                                    child: Text('최신순'),
                                  ),
                                  const PopupMenuItem(
                                    value: '인기순',
                                    child: Text('인기순'),
                                  ),
                                  const PopupMenuItem(
                                    value: '낮은 가격순',
                                    child: Text('낮은 가격순'),
                                  ),
                                  const PopupMenuItem(
                                    value: '높은 가격순',
                                    child: Text('높은 가격순'),
                                  ),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _getStringFromSortBy(sortBy),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        size: 20,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: result.products.length,
                            itemBuilder: (context, index) {
                              final product = result.products[index];
                              return ProductCardWidget(product: product);
                            },
                          ),
                          // 더 불러올 데이터가 있으면 로딩 인디케이터 표시
                          if (result.pagination.hasMore ?? false)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      SearchLoadingMore(:final result, :final query, :final sortBy) =>
        RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(searchNotifierProvider.notifier)
                .searchProducts(query, sortBy: sortBy);
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 검색 결과 목록 (로딩 중)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '전체 ${result.pagination.totalCount ?? 0}개',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          PopupMenuButton<String>(
                            initialValue: _getStringFromSortBy(sortBy),
                            onSelected: (value) async {
                              final newSortBy = _getSortByFromString(value);
                              await ref
                                  .read(searchNotifierProvider.notifier)
                                  .searchProducts(query, sortBy: newSortBy);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: '최신순',
                                child: Text('최신순'),
                              ),
                              const PopupMenuItem(
                                value: '인기순',
                                child: Text('인기순'),
                              ),
                              const PopupMenuItem(
                                value: '낮은 가격순',
                                child: Text('낮은 가격순'),
                              ),
                              const PopupMenuItem(
                                value: '높은 가격순',
                                child: Text('높은 가격순'),
                              ),
                            ],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _getStringFromSortBy(sortBy),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 20,
                                    color: Color(0xFF2563EB),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: result.products.length,
                        itemBuilder: (context, index) {
                          final product = result.products[index];
                          return ProductCardWidget(product: product);
                        },
                      ),
                      // 로딩 인디케이터
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    };
  }
}
