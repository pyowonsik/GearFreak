import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// 채팅 메시지 버블 위젯
class ChatMessageBubbleWidget extends StatelessWidget {
  /// ChatMessageBubbleWidget 생성자
  ///
  /// [text]는 메시지 텍스트입니다.
  /// [isMine]은 내 메시지인지 여부입니다.
  /// [time]은 메시지 시간입니다.
  /// [author]는 메시지 작성자 정보입니다.
  /// [showTime]은 시간을 표시할지 여부입니다. (기본값: true)
  /// [imageUrl]은 이미지 URL입니다. (있으면 이미지 메시지로 표시)
  const ChatMessageBubbleWidget({
    required this.text,
    required this.isMine,
    required this.time,
    required this.author,
    this.showTime = true,
    this.imageUrl,
    super.key,
  });

  /// 메시지 텍스트
  final String text;

  /// 내 메시지인지 여부
  final bool isMine;

  /// 메시지 시간
  final String time;

  /// 메시지 작성자 정보
  final types.User author;

  /// 시간을 표시할지 여부
  final bool showTime;

  /// 이미지 URL (있으면 이미지 메시지로 표시)
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            // 시간이 표시될 때만 아바타 표시 (같은 시간대면 아바타도 생략)
            if (showTime)
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF3F4F6),
                backgroundImage: author.imageUrl != null
                    ? CachedNetworkImageProvider(author.imageUrl!)
                    : null,
                child: author.imageUrl == null
                    ? Icon(
                        Icons.person,
                        color: Colors.grey.shade500,
                        size: 16,
                      )
                    : null,
              ),
            if (showTime) const SizedBox(width: 8),
            // 아바타가 없을 때 공간 확보
            if (!showTime) const SizedBox(width: 40),
          ],
          // 내 메시지는 시간이 왼쪽에 표시
          if (isMine && showTime) ...[
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child:
                imageUrl != null ? _buildImageMessage() : _buildTextMessage(),
          ),
          // 상대방 메시지는 시간이 오른쪽에 표시
          if (!isMine && showTime) ...[
            const SizedBox(width: 8),
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 텍스트 메시지 빌드
  Widget _buildTextMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isMine ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isMine ? Colors.white : const Color(0xFF1F2937),
          height: 1.4,
        ),
      ),
    );
  }

  /// 이미지 메시지 빌드 (카카오톡 스타일)
  Widget _buildImageMessage() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 220,
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              imageUrl: imageUrl!,
              cacheKey: _extractFileKeyFromUrl(imageUrl!),
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero, // 캐시된 이미지는 즉시 표시
              fadeOutDuration: Duration.zero,
              placeholderFadeInDuration: Duration.zero, // 플레이스홀더도 즉시 표시
              memCacheWidth: 440, // 2x 해상도 (220 * 2)
              memCacheHeight: 600, // 2x 해상도 (300 * 2)
              maxWidthDiskCache: 440,
              maxHeightDiskCache: 600,
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
            // 흰색 테두리 효과 (패딩 느낌)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// URL에서 파일 키 추출 (Presigned URL의 query parameter 제거)
  ///
  /// 예: https://bucket.s3.region.amazonaws.com/chatRoom/22/1/xxx.jpg?X-Amz-...
  /// -> chatRoom/22/1/xxx.jpg
  String _extractFileKeyFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // path에서 첫 번째 '/' 제거
      final path = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
      return path;
    } catch (e) {
      // 파싱 실패 시 원본 URL 반환
      return url;
    }
  }
}
