import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/view/gb_empty_view.dart';
import 'package:gear_freak_flutter/common/presentation/view/gb_error_view.dart';
import 'package:gear_freak_flutter/common/presentation/view/gb_loading_view.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/product_card_widget.dart';

/// 홈 화면
class HomeScreen extends ConsumerStatefulWidget {
  /// HomeScreen 생성자
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with PaginationScrollMixin {
  pod.ProductCategory? _selectedCategory; // null이면 전체

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

  /// 카테고리 이름 가져오기
  String _getCategoryName(pod.ProductCategory category) {
    switch (category) {
      case pod.ProductCategory.equipment:
        return '장비';
      case pod.ProductCategory.supplement:
        return '보충제';
      case pod.ProductCategory.clothing:
        return '의류';
      case pod.ProductCategory.shoes:
        return '신발';
      case pod.ProductCategory.etc:
        return '기타';
    }
  }

  /// 카테고리 아이콘 가져오기
  IconData _getCategoryIcon(pod.ProductCategory category) {
    switch (category) {
      case pod.ProductCategory.equipment:
        return Icons.settings_accessibility;
      case pod.ProductCategory.supplement:
        return Icons.medication;
      case pod.ProductCategory.clothing:
        return Icons.checkroom;
      case pod.ProductCategory.shoes:
        return Icons.downhill_skiing;
      case pod.ProductCategory.etc:
        return Icons.more_horiz;
    }
  }

  /// 카테고리 색상 가져오기
  Color _getCategoryColor(pod.ProductCategory category) {
    switch (category) {
      case pod.ProductCategory.equipment:
        return const Color(0xFF10B981);
      case pod.ProductCategory.supplement:
        return const Color(0xFFF59E0B);
      case pod.ProductCategory.clothing:
        return const Color(0xFFEF4444);
      case pod.ProductCategory.shoes:
        return const Color(0xFF8B5CF6);
      case pod.ProductCategory.etc:
        return const Color(0xFF6B7280);
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 [HomeScreen] initState 실행');

    // 무한 스크롤 초기화
    initPaginationScroll(
      onLoadMore: () {
        ref.read(productNotifierProvider.notifier).loadMoreProducts();
      },
      getPagination: () {
        final productState = ref.read(productNotifierProvider);
        if (productState is ProductPaginatedLoaded) {
          return productState.pagination;
        }
        return null;
      },
      isLoading: () {
        final productState = ref.read(productNotifierProvider);
        return productState is ProductPaginatedLoadingMore;
      },
      screenName: 'HomeScreen',
    );

    // 초기 상품 목록 로드 (전체)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  /// 카테고리 및 정렬에 따라 상품 로드
  Future<void> _loadProducts({pod.ProductSortBy? sortBy}) async {
    if (_selectedCategory == null) {
      // 전체
      await ref.read(productNotifierProvider.notifier).loadPaginatedProducts(
            limit: 20,
            sortBy: sortBy,
          );
    } else {
      // 특정 카테고리
      await ref
          .read(productNotifierProvider.notifier)
          .loadPaginatedProductsByCategory(
            category: _selectedCategory!,
            limit: 20,
            sortBy: sortBy,
          );
    }
  }

  @override
  void dispose() {
    debugPrint('🏠 [HomeScreen] dispose 실행');
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.shopping_bag,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('운동은 장비충'),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: switch (productState) {
        ProductLoading() => const GbLoadingView(),
        ProductError(:final message) => GbErrorView(
            message: message,
            onRetry: () {
              ref
                  .read(productNotifierProvider.notifier)
                  .loadPaginatedProducts(limit: 20);
            },
          ),
        ProductPaginatedLoaded(
          :final products,
          :final pagination,
          :final sortBy
        ) =>
          RefreshIndicator(
            onRefresh: () async {
              await _loadProducts(sortBy: sortBy);
            },
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 섹션 (필터링)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          // 전체 카테고리
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = null;
                              });
                              _loadProducts(sortBy: sortBy);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: _selectedCategory == null
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF2563EB)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: _selectedCategory == null
                                          ? Border.all(
                                              color: const Color(0xFF2563EB),
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Icon(
                                      Icons.grid_view,
                                      color: _selectedCategory == null
                                          ? Colors.white
                                          : const Color(0xFF2563EB),
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '전체',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _selectedCategory == null
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _selectedCategory == null
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 각 카테고리
                          ...pod.ProductCategory.values.map((category) {
                            final isSelected = _selectedCategory == category;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _loadProducts(sortBy: sortBy);
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _getCategoryColor(category)
                                            : _getCategoryColor(category)
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: isSelected
                                            ? Border.all(
                                                color:
                                                    _getCategoryColor(category),
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(category),
                                        color: isSelected
                                            ? Colors.white
                                            : _getCategoryColor(category),
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getCategoryName(category),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? _getCategoryColor(category)
                                            : const Color(0xFF4B5563),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 상품 목록 (무한 스크롤)
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
                              '전체 ${pagination.totalCount ?? 0}개',
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
                                await _loadProducts(sortBy: newSortBy);
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
                        if (products.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: const GbEmptyView(
                              message: '등록된 상품이 없습니다',
                            ),
                          )
                        else
                          Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return ProductCardWidget(
                                    product: products[index],
                                  );
                                },
                              ),
                              // 더 불러올 데이터가 있으면 로딩 인디케이터 표시
                              if (pagination.hasMore ?? false)
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ProductPaginatedLoadingMore(
          :final products,
          :final pagination,
          :final sortBy
        ) =>
          RefreshIndicator(
            onRefresh: () async {
              await _loadProducts(sortBy: sortBy);
            },
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 섹션 (필터링)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          // 전체 카테고리
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = null;
                              });
                              _loadProducts(sortBy: sortBy);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: _selectedCategory == null
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF2563EB)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: _selectedCategory == null
                                          ? Border.all(
                                              color: const Color(0xFF2563EB),
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Icon(
                                      Icons.grid_view,
                                      color: _selectedCategory == null
                                          ? Colors.white
                                          : const Color(0xFF2563EB),
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '전체',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _selectedCategory == null
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _selectedCategory == null
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 각 카테고리
                          ...pod.ProductCategory.values.map((category) {
                            final isSelected = _selectedCategory == category;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _loadProducts(sortBy: sortBy);
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _getCategoryColor(category)
                                            : _getCategoryColor(category)
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: isSelected
                                            ? Border.all(
                                                color:
                                                    _getCategoryColor(category),
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(category),
                                        color: isSelected
                                            ? Colors.white
                                            : _getCategoryColor(category),
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getCategoryName(category),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? _getCategoryColor(category)
                                            : const Color(0xFF4B5563),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 상품 목록 (무한 스크롤 중)
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
                              '전체 ${pagination.totalCount ?? 0}개',
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
                                await _loadProducts(sortBy: newSortBy);
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
                        if (products.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: const GbEmptyView(
                              message: '등록된 상품이 없습니다',
                            ),
                          )
                        else
                          Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return ProductCardWidget(
                                    product: products[index],
                                  );
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ProductInitial() => const GbLoadingView(),
      },
    );
  }
}
