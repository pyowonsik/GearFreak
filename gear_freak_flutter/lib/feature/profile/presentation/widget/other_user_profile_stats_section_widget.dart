import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/presentation.dart';

/// 다른 사용자 프로필 통계 섹션 위젯
class OtherUserProfileStatsSectionWidget extends StatelessWidget {
  /// OtherUserProfileStatsSectionWidget 생성자
  ///
  /// [sellingCount]는 판매중 상품 개수입니다.
  /// [soldCount]는 거래완료 상품 개수입니다.
  /// [reviewCount]는 후기 개수입니다.
  const OtherUserProfileStatsSectionWidget({
    required this.sellingCount,
    required this.soldCount,
    required this.reviewCount,
    super.key,
  });

  /// 판매중 상품 개수
  final int sellingCount;

  /// 거래완료 상품 개수
  final int soldCount;

  /// 후기 개수
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OtherUserProfileStatItemWidget(
              label: '판매중',
              value: '$sellingCount',
              icon: Icons.sell,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OtherUserProfileStatItemWidget(
              label: '거래완료',
              value: '$soldCount',
              icon: Icons.check_circle,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OtherUserProfileStatItemWidget(
              label: '후기',
              value: '$reviewCount',
              icon: Icons.star,
              color: const Color(0xFFFFB800),
            ),
          ),
        ],
      ),
    );
  }
}
