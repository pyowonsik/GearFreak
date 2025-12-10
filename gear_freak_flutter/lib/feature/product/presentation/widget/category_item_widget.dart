import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 카테고리 아이템 위젯
class CategoryItemWidget extends StatelessWidget {
  /// CategoryItemWidget 생성자
  ///
  /// [category]는 카테고리입니다.
  /// [name]는 카테고리 이름입니다.
  /// [iconName]는 카테고리 아이콘 이름입니다.
  /// [onTap]는 카테고리 아이템 탭 이벤트입니다.
  const CategoryItemWidget({
    required this.category,
    super.key,
    this.name,
    this.iconName,
    this.onTap,
  });

  /// 카테고리
  final pod.ProductCategory category;

  /// 카테고리 이름
  final String? name;

  /// 카테고리 아이콘 이름
  final String? iconName;

  /// 카테고리 아이템 탭 이벤트
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _getCategoryColor(category);
    final displayName = name ?? _getCategoryName(category);
    final icon = _getIconData(iconName ?? _getCategoryIcon(category));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors['background']!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: colors['icon'],
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> _getCategoryColor(pod.ProductCategory category) {
    switch (category) {
      case pod.ProductCategory.equipment:
        return {
          'icon': const Color(0xFF10B981),
          'background': const Color(0xFF10B981),
        };
      case pod.ProductCategory.supplement:
        return {
          'icon': const Color(0xFFF59E0B),
          'background': const Color(0xFFF59E0B),
        };
      case pod.ProductCategory.clothing:
        return {
          'icon': const Color(0xFFEF4444),
          'background': const Color(0xFFEF4444),
        };
      case pod.ProductCategory.shoes:
        return {
          'icon': const Color(0xFF8B5CF6),
          'background': const Color(0xFF8B5CF6),
        };
      case pod.ProductCategory.etc:
        return {
          'icon': const Color(0xFF6B7280),
          'background': const Color(0xFF6B7280),
        };
    }
  }

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

  String _getCategoryIcon(pod.ProductCategory category) {
    switch (category) {
      case pod.ProductCategory.equipment:
        return 'settings_accessibility';
      case pod.ProductCategory.supplement:
        return 'medication';
      case pod.ProductCategory.clothing:
        return 'checkroom';
      case pod.ProductCategory.shoes:
        return 'downhill_skiing';
      case pod.ProductCategory.etc:
        return 'more_horiz';
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'grid_view':
        return Icons.grid_view;
      case 'settings_accessibility':
        return Icons.settings_accessibility;
      case 'medication':
        return Icons.medication;
      case 'checkroom':
        return Icons.checkroom;
      case 'downhill_skiing':
        return Icons.downhill_skiing;
      default:
        return Icons.more_horiz;
    }
  }
}
