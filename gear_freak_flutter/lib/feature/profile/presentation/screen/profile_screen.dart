import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/component/gb_dialog.dart';
import 'package:gear_freak_flutter/common/component/gb_loading_view.dart';
import 'package:gear_freak_flutter/common/component/gb_snackbar.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/profile/di/profile_providers.dart';
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
      appBar: AppBar(
        title: const Text('내 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: profileState.isLoading
          ? const GbLoadingView()
          : profileState.profile == null
              ? const Center(child: Text('프로필을 불러올 수 없습니다'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // 프로필 정보
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFFF3F4F6),
                              child: Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profileState.profile!.nickname,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profileState.profile!.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('프로필 편집'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 활동 통계
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              '판매중',
                              '${profileState.profile!.sellingCount}',
                            ),
                            _buildStatItem(
                              '거래완료',
                              '${profileState.profile!.soldCount}',
                            ),
                            _buildStatItem(
                              '관심목록',
                              '${profileState.profile!.favoriteCount}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 메뉴 리스트c
                      Column(
                        children: [
                          _buildMenuItem(
                            Icons.shopping_bag_outlined,
                            '내 상품 관리',
                          ),
                          _buildMenuItem(Icons.receipt_long_outlined, '거래 내역'),
                          _buildMenuItem(Icons.favorite_outline, '관심 목록'),
                          _buildMenuItem(Icons.star_outline, '후기 관리'),
                          _buildMenuItem(Icons.help_outline, '고객 센터'),
                          _buildMenuItem(Icons.info_outline, '앱 정보'),
                          _buildMenuItem(
                            Icons.logout_outlined,
                            '로그아웃',
                            onTap: _handleLogout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4B5563)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1F2937),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF9CA3AF),
      ),
      onTap: onTap,
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
}
