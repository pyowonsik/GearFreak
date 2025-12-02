import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/widget.dart';

/// 페이지네이션된 상품 목록 View
class PaginatedProductListView extends StatelessWidget {
  /// PaginatedProductListView 생성자
  ///
  /// [products]는 상품 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [scrollController]는 스크롤 컨트롤러입니다.
  /// [isLoadingMore]는 더 불러오는 중인지 여부입니다.
  const PaginatedProductListView({
    required this.products,
    required this.pagination,
    required this.scrollController,
    required this.isLoadingMore,
    super.key,
  });

  /// 상품 목록
  final List<pod.Product> products;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 스크롤 컨트롤러
  final ScrollController scrollController;

  /// 더 불러오는 중인지 여부
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const GbEmptyView(
        message: '등록된 상품이 없습니다',
      );
    }

    // isLoadingMore이면 항상 마지막에 로딩 인디케이터 표시
    // 아니면 hasMore일 때만 표시
    final itemCount = isLoadingMore
        ? products.length + 1
        : products.length + ((pagination.hasMore ?? false) ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == products.length) {
          // 마지막에 로딩 인디케이터 표시
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ProductCardWidget(
          product: products[index],
        );
      },
    );
  }
}
