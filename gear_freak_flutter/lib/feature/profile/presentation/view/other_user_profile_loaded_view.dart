import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/profile/presentation/widget/widget.dart';

/// 다른 사용자 프로필이 로드된 상태의 View
class OtherUserProfileLoadedView extends StatelessWidget {
  /// OtherUserProfileLoadedView 생성자
  ///
  /// [user]는 다른 사용자 정보입니다.
  /// [stats]는 상품 통계 정보입니다 (선택).
  const OtherUserProfileLoadedView({
    required this.user,
    this.stats,
    super.key,
  });

  /// 다른 사용자 정보
  final pod.User user;

  /// 상품 통계 정보 (선택)
  final pod.ProductStatsDto? stats;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: OtherUserProfileHeaderWidget(user: user),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 24),
              OtherUserProfileStatsSectionWidget(
                sellingCount: stats?.sellingCount ?? 0,
                soldCount: stats?.soldCount ?? 0,
                reviewCount: stats?.reviewCount ?? 0,
              ),
              const SizedBox(height: 24),
              const OtherUserProfileProductsSectionWidget(),
              const SizedBox(height: 24),
              const OtherUserProfileReviewSectionWidget(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
