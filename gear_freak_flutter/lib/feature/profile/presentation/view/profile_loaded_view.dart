import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/profile/presentation/presentation.dart';

/// 프로필 화면이 로드된 상태의 View
class ProfileLoadedView extends StatelessWidget {
  /// ProfileLoadedView 생성자
  ///
  /// [user]는 사용자 정보입니다.
  /// [stats]는 상품 통계 정보입니다.
  /// [onEditProfile]는 프로필 편집 버튼 클릭 콜백입니다.
  /// [onLogout]는 로그아웃 메뉴 클릭 콜백입니다.
  /// [onAppInfo]는 앱 정보 메뉴 클릭 콜백입니다.
  /// [onCustomerCenter]는 고객 센터 메뉴 클릭 콜백입니다.
  const ProfileLoadedView({
    required this.user,
    required this.onLogout,
    this.stats,
    this.onEditProfile,
    this.onAppInfo,
    this.onCustomerCenter,
    this.onSellingTap,
    this.onSoldTap,
    this.onFavoriteTap,
    this.onReviewManagement,
    super.key,
  });

  /// 사용자 정보
  final pod.User user;

  /// 상품 통계 정보
  final pod.ProductStatsDto? stats;

  /// 프로필 편집 버튼 클릭 콜백
  final VoidCallback? onEditProfile;

  /// 로그아웃 메뉴 클릭 콜백
  final VoidCallback onLogout;

  /// 앱 정보 메뉴 클릭 콜백
  final VoidCallback? onAppInfo;

  /// 고객 센터 메뉴 클릭 콜백
  final VoidCallback? onCustomerCenter;

  /// 판매중 통계 클릭 콜백
  final VoidCallback? onSellingTap;

  /// 거래완료 통계 클릭 콜백
  final VoidCallback? onSoldTap;

  /// 관심목록 통계 클릭 콜백
  final VoidCallback? onFavoriteTap;

  /// 후기 관리 메뉴 클릭 콜백
  final VoidCallback? onReviewManagement;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 프로필 정보
          ProfileInfoSectionWidget(
            user: user,
            onEditProfile: onEditProfile,
          ),
          const SizedBox(height: 8),
          // 활동 통계
          ProfileStatsSectionWidget(
            sellingCount: stats?.sellingCount ?? 0,
            soldCount: stats?.soldCount ?? 0,
            favoriteCount: stats?.favoriteCount ?? 0,
            onSellingTap: onSellingTap,
            onSoldTap: onSoldTap,
            onFavoriteTap: onFavoriteTap,
          ),
          const SizedBox(height: 8),
          // 메뉴 리스트
          Column(
            children: [
              ProfileMenuItemWidget(
                icon: Icons.star_outline,
                title: '후기 관리',
                onTap: onReviewManagement,
              ),
              // ProfileMenuItemWidget(
              //   icon: Icons.help_outline,
              //   title: '고객 센터',
              //   onTap: onCustomerCenter,
              // ),
              // ProfileMenuItemWidget(
              //   icon: Icons.info_outline,
              //   title: '앱 정보',
              //   onTap: onAppInfo,
              // ),
              ProfileMenuItemWidget(
                icon: Icons.logout_outlined,
                title: '로그아웃',
                onTap: onLogout,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
