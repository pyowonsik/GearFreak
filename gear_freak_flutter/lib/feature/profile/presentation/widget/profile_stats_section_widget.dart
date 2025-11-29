import 'package:flutter/material.dart';

/// 프로필 활동 통계 섹션 위젯
class ProfileStatsSectionWidget extends StatelessWidget {
  /// ProfileStatsSectionWidget 생성자
  ///
  /// [sellingCount]는 판매중 상품 개수입니다.
  /// [soldCount]는 거래완료 상품 개수입니다.
  /// [favoriteCount]는 관심목록 상품 개수입니다.
  const ProfileStatsSectionWidget({
    required this.sellingCount,
    required this.soldCount,
    required this.favoriteCount,
    super.key,
  });

  /// 판매중 상품 개수
  final int sellingCount;

  /// 거래완료 상품 개수
  final int soldCount;

  /// 관심목록 상품 개수
  final int favoriteCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('판매중', '$sellingCount'),
          _buildStatItem('거래완료', '$soldCount'),
          _buildStatItem('관심목록', '$favoriteCount'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
