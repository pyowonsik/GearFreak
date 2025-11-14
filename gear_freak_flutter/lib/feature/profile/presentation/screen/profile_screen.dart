import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/profile_providers.dart';

/// 프로필 화면
class ProfileScreen extends ConsumerStatefulWidget {
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
          ? const Center(child: CircularProgressIndicator())
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
                            _buildStatItem('판매중', '${profileState.profile!.sellingCount}'),
                            _buildStatItem('거래완료', '${profileState.profile!.soldCount}'),
                            _buildStatItem('관심목록', '${profileState.profile!.favoriteCount}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 메뉴 리스트
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            _buildMenuItem(Icons.shopping_bag_outlined, '내 상품 관리'),
                            _buildMenuItem(Icons.receipt_long_outlined, '거래 내역'),
                            _buildMenuItem(Icons.favorite_outline, '관심 목록'),
                            _buildMenuItem(Icons.star_outline, '후기 관리'),
                            _buildMenuItem(Icons.help_outline, '고객 센터'),
                            _buildMenuItem(Icons.info_outline, '앱 정보'),
                          ],
                        ),
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

  Widget _buildMenuItem(IconData icon, String title) {
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
      onTap: () {},
    );
  }
}

