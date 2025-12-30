import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/profile/presentation/presentation.dart';
import 'package:go_router/go_router.dart';

/// 다른 사용자 프로필이 로드된 상태의 View
class OtherUserProfileLoadedView extends StatelessWidget {
  /// OtherUserProfileLoadedView 생성자
  ///
  /// [user]는 다른 사용자 정보입니다.
  /// [stats]는 상품 통계 정보입니다 (선택).
  /// [reviews]는 후기 목록입니다 (선택, 최대 3개).
  /// [averageRating]는 평균 평점입니다 (선택).
  /// [products]는 상품 목록입니다 (선택, 최대 5개).
  const OtherUserProfileLoadedView({
    required this.user,
    this.stats,
    this.reviews,
    this.averageRating,
    this.products,
    super.key,
  });

  /// 다른 사용자 정보
  final pod.User user;

  /// 상품 통계 정보 (선택)
  final pod.ProductStatsDto? stats;

  /// 후기 목록 (선택, 최대 3개)
  final List<pod.TransactionReviewResponseDto>? reviews;

  /// 평균 평점 (선택)
  final double? averageRating;

  /// 상품 목록 (선택, 최대 5개)
  final List<pod.Product>? products;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
              OtherUserProfileProductsSectionWidget(
                products: products ?? [],
                onViewAllTap: () {
                  final userId = user.id;
                  if (userId != null) {
                    context.push('/profile/user/$userId/products');
                  }
                },
              ),
              const SizedBox(height: 24),
              OtherUserProfileReviewSectionWidget(
                reviews: reviews ?? [],
                averageRating: averageRating,
                reviewCount: stats?.reviewCount,
                onViewAllTap: () {
                  final userId = user.id;
                  if (userId != null) {
                    context.push('/profile/user/$userId/reviews');
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
