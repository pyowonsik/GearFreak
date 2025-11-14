import 'package:flutter/material.dart';
import '../../domain/entity/product.dart';

/// 카테고리 아이템 위젯
class CategoryItemWidget extends StatelessWidget {
  final Category category;

  const CategoryItemWidget({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getCategoryColor(category.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors['background']!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIconData(category.icon),
              color: colors['icon'],
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'all':
        return {
          'icon': const Color(0xFF2563EB),
          'background': const Color(0xFF2563EB)
        };
      case 'equipment':
        return {
          'icon': const Color(0xFF10B981),
          'background': const Color(0xFF10B981)
        };
      case 'supplement':
        return {
          'icon': const Color(0xFFF59E0B),
          'background': const Color(0xFFF59E0B)
        };
      case 'clothing':
        return {
          'icon': const Color(0xFFEF4444),
          'background': const Color(0xFFEF4444)
        };
      case 'shoes':
        return {
          'icon': const Color(0xFF8B5CF6),
          'background': const Color(0xFF8B5CF6)
        };
      default:
        return {
          'icon': const Color(0xFF6B7280),
          'background': const Color(0xFF6B7280)
        };
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
