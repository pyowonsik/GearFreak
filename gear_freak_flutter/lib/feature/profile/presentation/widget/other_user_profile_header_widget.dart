import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 다른 사용자 프로필 헤더 위젯
class OtherUserProfileHeaderWidget extends StatelessWidget {
  /// OtherUserProfileHeaderWidget 생성자
  ///
  /// [user]는 다른 사용자 정보입니다.
  const OtherUserProfileHeaderWidget({
    required this.user,
    super.key,
  });

  /// 다른 사용자 정보
  final pod.User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.white,
                    backgroundImage: (user.profileImageUrl != null &&
                            user.profileImageUrl!.isNotEmpty)
                        ? CachedNetworkImageProvider(user.profileImageUrl!)
                        : null,
                    child: (user.profileImageUrl == null ||
                            user.profileImageUrl!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 56,
                            color: Color(0xFF9CA3AF),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.nickname ?? '사용자',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified_user,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  '인증된 판매자',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

