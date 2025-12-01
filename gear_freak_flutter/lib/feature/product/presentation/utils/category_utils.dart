import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 카테고리 관련 유틸리티
class CategoryUtils {
  /// 카테고리 이름 가져오기
  static String getCategoryName(pod.ProductCategory category) {
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
  static IconData getCategoryIcon(pod.ProductCategory category) {
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
  static Color getCategoryColor(pod.ProductCategory category) {
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
}

