import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/presentation/utils/category_utils.dart';

/// 카테고리 필터링 섹션 컴포넌트
/// 여러 feature에서 재사용 가능한 컴포넌트
class CategoryFilterSectionComponent extends StatelessWidget {
  /// CategoryFilterSectionComponent 생성자
  ///
  /// [selectedCategory]는 선택된 카테고리입니다.
  /// [onCategoryChanged]는 카테고리 변경 콜백입니다.
  const CategoryFilterSectionComponent({
    required this.selectedCategory,
    required this.onCategoryChanged,
    super.key,
  });

  /// 선택된 카테고리
  final pod.ProductCategory? selectedCategory;

  /// 카테고리 변경 콜백
  final ValueChanged<pod.ProductCategory?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                onCategoryChanged(null);
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
                        color: selectedCategory == null
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: selectedCategory == null
                            ? Border.all(
                                color: const Color(0xFF2563EB),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        Icons.grid_view,
                        color: selectedCategory == null
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
                        fontWeight: selectedCategory == null
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: selectedCategory == null
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
              final isSelected = selectedCategory == category;
              final categoryColor = CategoryUtils.getCategoryColor(category);
              return GestureDetector(
                onTap: () {
                  onCategoryChanged(category);
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
                          color: isSelected
                              ? categoryColor
                              : categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: categoryColor,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          CategoryUtils.getCategoryIcon(category),
                          color: isSelected ? Colors.white : categoryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CategoryUtils.getCategoryName(category),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? categoryColor
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
    );
  }
}
