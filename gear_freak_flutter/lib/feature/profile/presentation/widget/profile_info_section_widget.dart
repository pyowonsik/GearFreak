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
      child: Column(
        children: [
          // 프로필 이미지
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
          const SizedBox(height: 16),
          // 닉네임과 ID를 한 줄로 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _getNicknameWithoutId(user.nickname ?? ''),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
              if (_hasId(user.nickname ?? ''))
                Text(
                  _getId(user.nickname ?? ''),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                ),
            ],
          ),
          const SizedBox(height: 4),
          // 이메일
          Text(
            user.userInfo?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 프로필 편집 버튼을 전체 너비로 배치
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('프로필 편집'),
            ),
          ),
        ],
      ),
    );
  }

  /// 닉네임에서 ID 부분을 제거한 이름 반환
  /// 예: "장비충#1234567890" -> "장비충"
  String _getNicknameWithoutId(String nickname) {
    final index = nickname.indexOf('#');
    if (index == -1) {
      return nickname;
    }
    return nickname.substring(0, index);
  }

  /// 닉네임에 ID가 있는지 확인
  bool _hasId(String nickname) {
    return nickname.contains('#');
  }

  /// 닉네임에서 ID 부분만 추출
  /// 예: "장비충#1234567890" -> "#1234567890"
  String _getId(String nickname) {
    final index = nickname.indexOf('#');
    if (index == -1) {
      return '';
    }
    return nickname.substring(index);
  }
}
