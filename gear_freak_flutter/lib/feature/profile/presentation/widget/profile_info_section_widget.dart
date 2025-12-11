import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 프로필 정보 섹션 위젯
class ProfileInfoSectionWidget extends StatelessWidget {
  /// ProfileInfoSectionWidget 생성자
  ///
  /// [user]는 사용자 정보입니다.
  /// [onEditProfile]는 프로필 편집 버튼 클릭 콜백입니다.
  const ProfileInfoSectionWidget({
    required this.user,
    this.onEditProfile,
    super.key,
  });

  /// 사용자 정보
  final pod.User user;

  /// 프로필 편집 버튼 클릭 콜백
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFFF3F4F6),
              child: user.profileImageUrl != null &&
                      user.profileImageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user.profileImageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholderFadeInDuration: Duration.zero,
                      memCacheWidth: 120, // 표시 크기보다 약간 크게 (80 * 1.5)
                      memCacheHeight: 120,
                      maxWidthDiskCache: 120,
                      maxHeightDiskCache: 120,
                      useOldImageOnUrlChange: true,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.grey.shade500,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.grey.shade500,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.userInfo?.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onEditProfile,
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
    );
  }
}
