import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/presentation.dart';

/// 프로필 활동 통계 섹션 위젯
class ProfileStatsSectionWidget extends StatelessWidget {
  /// ProfileStatsSectionWidget 생성자
  ///
  /// [sellingCount]는 판매중 상품 개수입니다.
  /// [soldCount]는 거래완료 상품 개수입니다.
  /// [favoriteCount]는 관심목록 상품 개수입니다.
  /// [onSellingTap]는 판매중 통계 클릭 콜백입니다.
  /// [onSoldTap]는 거래완료 통계 클릭 콜백입니다.
  /// [onFavoriteTap]는 관심목록 통계 클릭 콜백입니다.
  const ProfileStatsSectionWidget({
    required this.sellingCount,
    required this.soldCount,
    required this.favoriteCount,
    this.onSellingTap,
    this.onSoldTap,
    this.onFavoriteTap,
    super.key,
  });

  /// 판매중 상품 개수
  final int sellingCount;

  /// 거래완료 상품 개수
  final int soldCount;

  /// 관심목록 상품 개수
  final int favoriteCount;

  /// 판매중 통계 클릭 콜백
  final VoidCallback? onSellingTap;

  /// 거래완료 통계 클릭 콜백
  final VoidCallback? onSoldTap;

  /// 관심목록 통계 클릭 콜백
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ProfileStatItemWidget(
            label: '판매중',
            value: '$sellingCount',
            onTap: onSellingTap,
          ),
          ProfileStatItemWidget(
            label: '거래완료',
            value: '$soldCount',
            onTap: onSoldTap,
          ),
          ProfileStatItemWidget(
            label: '관심목록',
            value: '$favoriteCount',
            onTap: onFavoriteTap,
          ),
        ],
      ),
    );
  }
}
