import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/core/util/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/notification/di/notification_providers.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/presentation.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';
import 'package:go_router/go_router.dart';

/// 홈 화면
class HomePage extends ConsumerStatefulWidget {
  /// HomePage 생성자
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with PaginationScrollMixin {
  pod.ProductCategory? _selectedCategory; // null이면 전체
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 [HomePage] initState 실행');

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
      screenName: 'HomePage',
    );

    // 초기 상품 목록 로드 (전체)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
      // 읽지 않은 알림 개수 조회 - totalUnreadNotificationCountProvider를 통해 처리
      // ignore: unused_result
      ref.refresh(totalUnreadNotificationCountProvider);
    });

    // 앱 생명주기 감지 (백그라운드 -> 포그라운드)
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        if (state == AppLifecycleState.resumed) {
          if (!mounted) return;
          // 읽지 않은 알림 개수 갱신
          // ignore: unused_result
          ref.refresh(totalUnreadNotificationCountProvider);
        }
      },
    );
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
            sortBy: sortBy,
          );
    }
  }

  @override
  void dispose() {
    debugPrint('🏠 [HomePage] dispose 실행');
    _lifecycleListener?.dispose();
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);
    // 읽지 않은 알림 개수 조회
    final unreadNotificationCountAsync =
        ref.watch(totalUnreadNotificationCountProvider);
    final unreadCount = unreadNotificationCountAsync.value ?? 0;

    return Scaffold(
      appBar: GbAppBar(
        title: const Text('운동은 장비충'),
        prefix: Icon(
          Icons.shopping_bag,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () async {
                  // 알림 화면으로 이동하고 결과 대기
                  await context.push('/notifications');
                  // 알림 화면에서 돌아온 경우 읽지 않은 알림 개수 다시 조회
                  if (mounted) {
                    // ignore: unused_result
                    ref.refresh(totalUnreadNotificationCountProvider);
                  }
                },
              ),
              // 읽지 않은 알림이 있을 때만 빨간 점 표시
              if (unreadCount > 0)
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
        ) ||
        ProductPaginatedLoadingMore(
          :final products,
          :final pagination,
          :final sortBy
        ) =>
          HomeLoadedView(
            key: const ValueKey('home_loaded'),
            products: products,
            pagination: pagination,
            sortBy: sortBy,
            selectedCategory: _selectedCategory,
            scrollController: scrollController!,
            isLoadingMore: productState is ProductPaginatedLoadingMore,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
              _loadProducts(sortBy: sortBy);
            },
            onSortChanged: (newSortBy) async {
              await _loadProducts(sortBy: newSortBy);
            },
            onRefresh: () async {
              await _loadProducts(sortBy: sortBy);
            },
          ),
        ProductInitial() => const GbLoadingView(),
      },
    );
  }
}
