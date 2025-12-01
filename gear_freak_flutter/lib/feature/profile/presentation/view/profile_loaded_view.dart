import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/feature/profile/domain/domain.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/widget/widget.dart';



/// 프로필 화면이 로드된 상태의 View
class ProfileLoadedView extends StatelessWidget {
  /// ProfileLoadedView 생성자
  ///
  /// [profile]는 프로필 정보입니다.
  /// [onEditProfile]는 프로필 편집 버튼 클릭 콜백입니다.
  /// [onLogout]는 로그아웃 메뉴 클릭 콜백입니다.
  const ProfileLoadedView({
    required this.profile,
    required this.onLogout,
    this.onEditProfile,
    super.key,
  });

  /// 프로필 정보
  final UserProfile profile;

  /// 프로필 편집 버튼 클릭 콜백
  final VoidCallback? onEditProfile;

  /// 로그아웃 메뉴 클릭 콜백
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 프로필 정보
          ProfileInfoSectionWidget(
            profile: profile,
            onEditProfile: onEditProfile,
          ),
          const SizedBox(height: 8),
          // 활동 통계
          ProfileStatsSectionWidget(
            sellingCount: profile.sellingCount,
            soldCount: profile.soldCount,
            favoriteCount: profile.favoriteCount,
          ),
          const SizedBox(height: 8),
          // 메뉴 리스트
          Column(
            children: [
              const ProfileMenuItemWidget(
                icon: Icons.shopping_bag_outlined,
                title: '내 상품 관리',
              ),
              const ProfileMenuItemWidget(
                icon: Icons.receipt_long_outlined,
                title: '거래 내역',
              ),
              const ProfileMenuItemWidget(
                icon: Icons.favorite_outline,
                title: '관심 목록',
              ),
              const ProfileMenuItemWidget(
                icon: Icons.star_outline,
                title: '후기 관리',
              ),
              const ProfileMenuItemWidget(
                icon: Icons.help_outline,
                title: '고객 센터',
              ),
              const ProfileMenuItemWidget(
                icon: Icons.info_outline,
                title: '앱 정보',
              ),
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
