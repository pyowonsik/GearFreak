import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/profile/di/profile_providers.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/other_user_profile_state.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/view/view.dart';

/// 다른 사용자 프로필 화면
class OtherUserProfileScreen extends ConsumerStatefulWidget {
  /// OtherUserProfileScreen 생성자
  ///
  /// [userId]는 다른 사용자의 아이디입니다.
  const OtherUserProfileScreen({
    /// userId
    required this.userId,
    super.key,
  });

  /// 다른 사용자의 아이디
  final String userId;

  @override
  ConsumerState<OtherUserProfileScreen> createState() =>
      _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState
    extends ConsumerState<OtherUserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // 사용자 프로필 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = int.tryParse(widget.userId);
      if (userId != null) {
        final notifier = ref.read(otherUserProfileNotifierProvider.notifier);
        // 프로필 로드 후 통계, 상품, 후기도 로드
        notifier.loadUserProfile(userId).then((_) {
          notifier
            ..loadProductStats(userId)
            ..loadProducts(userId)
            ..loadReviews(userId);
        });
      }
    });
  }

  /// 새로고침 처리
  Future<void> _onRefresh() async {
    final userId = int.tryParse(widget.userId);
    if (userId != null) {
      final notifier = ref.read(otherUserProfileNotifierProvider.notifier);
      // 프로필 로드 후 통계, 상품, 후기도 로드
      await notifier.loadUserProfile(userId);
      await Future.wait([
        notifier.loadProductStats(userId),
        notifier.loadProducts(userId),
        notifier.loadReviews(userId),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otherUserProfileNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: switch (state) {
        OtherUserProfileInitial() ||
        OtherUserProfileLoading() =>
          const GbLoadingView(),
        OtherUserProfileError(:final message) => GbErrorView(
            message: message,
            onRetry: () {
              final userId = int.tryParse(widget.userId);
              if (userId != null) {
                ref
                    .read(otherUserProfileNotifierProvider.notifier)
                    .loadUserProfile(userId);
              }
            },
          ),
        OtherUserProfileLoaded(
          :final user,
          :final stats,
          :final reviews,
          :final averageRating,
          :final products
        ) =>
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: OtherUserProfileLoadedView(
              user: user,
              stats: stats,
              reviews: reviews,
              averageRating: averageRating,
              products: products,
            ),
          ),
      },
    );
  }
}
