import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/profile/presentation/widget/widget.dart';

/// 다른 사용자 프로필이 로드된 상태의 View
class OtherUserProfileLoadedView extends StatelessWidget {
  /// OtherUserProfileLoadedView 생성자
  ///
  /// [user]는 다른 사용자 정보입니다.
  const OtherUserProfileLoadedView({
    required this.user,
    super.key,
  });

  /// 다른 사용자 정보
  final pod.User user;

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
        const SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 24),
              OtherUserProfileStatsSectionWidget(
                sellingCount: 12,
                soldCount: 45,
                reviewCount: 38,
              ),
              SizedBox(height: 24),
              OtherUserProfileProductsSectionWidget(),
              SizedBox(height: 24),
              OtherUserProfileReviewSectionWidget(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
