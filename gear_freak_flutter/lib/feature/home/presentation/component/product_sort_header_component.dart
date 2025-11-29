import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/home/presentation/utils/product_sort_utils.dart';

/// 상품 목록 정렬 헤더 컴포넌트
/// 여러 feature에서 재사용 가능한 컴포넌트
class ProductSortHeaderComponent extends StatelessWidget {
  /// ProductSortHeaderComponent 생성자
  ///
  /// [totalCount]는 전체 상품 개수입니다.
  /// [sortBy]는 정렬 옵션입니다.
  /// [onSortChanged]는 정렬 변경 콜백입니다.
  const ProductSortHeaderComponent({
    required this.totalCount,
    required this.sortBy,
    required this.onSortChanged,
    super.key,
  });

  /// 전체 상품 개수
  final int totalCount;

  /// 정렬 옵션
  final pod.ProductSortBy? sortBy;

  /// 정렬 변경 콜백
  final ValueChanged<pod.ProductSortBy?> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '전체 $totalCount개',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        PopupMenuButton<String>(
          initialValue: ProductSortUtils.getStringFromSortBy(sortBy),
          onSelected: (value) {
            final newSortBy = ProductSortUtils.getSortByFromString(value);
            onSortChanged(newSortBy);
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
                  ProductSortUtils.getStringFromSortBy(sortBy),
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
    );
  }
}
