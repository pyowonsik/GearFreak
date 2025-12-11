import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/common/presentation/widget/full_screen_image_viewer.dart';
import 'package:gear_freak_flutter/common/presentation/widget/full_screen_video_viewer.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/utils/chat_util.dart';

/// 채팅 이미지/동영상 메시지 위젯
class ChatImageMessageWidget extends StatelessWidget {
  /// ChatImageMessageWidget 생성자
  ///
  /// [imageUrl]은 이미지/썸네일 URL입니다.
  /// [isVideo]는 동영상인지 여부입니다. (기본값: false)
  /// [videoUrl]은 동영상 URL입니다. (동영상인 경우)
  const ChatImageMessageWidget({
    required this.imageUrl,
    this.isVideo = false,
    this.videoUrl,
    super.key,
  });

  /// 이미지/썸네일 URL
  final String imageUrl;

  /// 동영상인지 여부
  final bool isVideo;

  /// 동영상 URL (동영상인 경우)
  final String? videoUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isVideo && videoUrl != null) {
          // 동영상인 경우 동영상 재생
          FullScreenVideoViewer.show(
            context: context,
            videoUrl: videoUrl!,
            thumbnailUrl: imageUrl,
          );
        } else {
          // 이미지인 경우 전체 화면으로 표시
          FullScreenImageViewer.show(
            context: context,
            imageUrl: imageUrl,
          );
        }
      },
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 220,
          maxHeight: 300,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // 이미지
              CachedNetworkImage(
                imageUrl: imageUrl,
                cacheKey: ChatUtil.extractFileKeyFromUrl(imageUrl),
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero, // 캐시된 이미지는 즉시 표시
                fadeOutDuration: Duration.zero,
                placeholderFadeInDuration: Duration.zero, // 플레이스홀더도 즉시 표시
                memCacheWidth: 300, // 표시 크기보다 약간 크게 (220 * 1.36)
                memCacheHeight: 400, // 표시 크기보다 약간 크게 (300 * 1.33)
                maxWidthDiskCache: 300,
                maxHeightDiskCache: 400,
                useOldImageOnUrlChange: true, // URL이 변경되어도 이전 이미지 유지
                placeholder: (context, url) => Container(
                  width: 220,
                  height: 150,
                  color: const Color(0xFFF3F4F6),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 220,
                  height: 150,
                  color: const Color(0xFFF3F4F6),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
              // 동영상인 경우 재생 버튼 오버레이
              if (isVideo)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              // 흰색 테두리 효과 (패딩 느낌)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
