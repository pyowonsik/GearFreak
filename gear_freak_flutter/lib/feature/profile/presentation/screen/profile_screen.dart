import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/profile/di/profile_providers.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/widget/widget.dart';
import 'package:go_router/go_router.dart';

/// 프로필 화면
class ProfileScreen extends ConsumerStatefulWidget {
  /// ProfileScreen 생성자
  ///
  /// [key]는 화면 키입니다.
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: const ProfileAppBarWidget(),
      body: profileState.isLoading
          ? const GbLoadingView()
          : profileState.profile == null
              ? const GbEmptyView(
                  message: '프로필을 불러올 수 없습니다',
                )
              : ProfileLoadedView(
                  profile: profileState.profile!,
                  onLogout: _handleLogout,
                  onEditProfile: _handleEditProfile,
                ),
    );
  }

  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    // 로그아웃 확인 다이얼로그 표시
    final shouldLogout = await GbDialog.show(
      context: context,
      title: '로그아웃',
      content: '정말 로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
      confirmColor: Colors.red,
    );

    if (shouldLogout != true || !mounted) return;

    try {
      // 로그아웃 실행
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.logout();

      if (!mounted) return;

      // 다음 프레임에서 라우팅 (provider 재빌드 후)
      // 이렇게 하면 authNotifierProvider의 상태 변경이 완료된 후 Guard가 실행됩니다
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/login');
        }
      });
    } catch (e) {
      // 로그아웃 실패 시 에러 메시지 표시
      if (!mounted) return;

      GbSnackBar.showError(context, '로그아웃 실패: $e');
    }
  }

  /// 프로필 편집 처리
  void _handleEditProfile() {
    context.push('/profile/edit');
  }
}
