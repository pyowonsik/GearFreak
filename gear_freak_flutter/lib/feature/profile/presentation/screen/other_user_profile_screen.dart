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
        ref
            .read(otherUserProfileNotifierProvider.notifier)
            .loadUserProfile(userId);
      }
    });
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
        OtherUserProfileLoaded(:final user) => OtherUserProfileLoadedView(
            user: user,
          ),
      },
    );
  }
}
