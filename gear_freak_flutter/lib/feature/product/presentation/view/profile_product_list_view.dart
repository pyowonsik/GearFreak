import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/presentation/widget/widget.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';

/// 프로필 화면용 상품 목록 View (카테고리 필터 없음)
class ProfileProductListView extends ConsumerWidget {
  /// ProfileProductListView 생성자
  ///
  /// [products]는 상품 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [scrollController]는 스크롤 컨트롤러입니다.
  /// [onRefresh]는 새로고침 콜백입니다.
  /// [isLoadingMore]는 더 불러오는 중인지 여부입니다.
  const ProfileProductListView({
    required this.products,
    required this.pagination,
    required this.scrollController,
    required this.onRefresh,
    this.isLoadingMore = false,
    super.key,
  });

  /// 상품 목록
  final List<pod.Product> products;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 스크롤 컨트롤러
  final ScrollController scrollController;

  /// 새로고침 콜백
  final Future<void> Function() onRefresh;

  /// 더 불러오는 중인지 여부
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: GbEmptyView(
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
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
