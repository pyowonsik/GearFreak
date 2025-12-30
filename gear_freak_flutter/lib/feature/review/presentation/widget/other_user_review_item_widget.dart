import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/core/util/format_utils.dart'
    show formatRelativeTime;
import 'package:go_router/go_router.dart';

/// 후기 아이템 위젯 (다른 사용자 후기 목록 화면용)
class OtherUserReviewItemWidget extends StatelessWidget {
  /// OtherUserReviewItemWidget 생성자
  const OtherUserReviewItemWidget({
    required this.review,
    super.key,
  });

  /// 후기 데이터
  final pod.TransactionReviewResponseDto review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 및 평점
          Row(
            children: [
              // 프로필 이미지 (클릭 가능)
              GestureDetector(
                onTap: () {
                  // 리뷰 작성자 프로필 화면으로 이동
                  final reviewerId = review.reviewerId;
                  context.push('/profile/user/$reviewerId');
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFF3F4F6),
                  backgroundImage: review.reviewerProfileImageUrl != null
                      ? CachedNetworkImageProvider(
                          review.reviewerProfileImageUrl!,
                        )
                      : null,
                  child: review.reviewerProfileImageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 24,
                          color: Color(0xFF9CA3AF),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerNickname ?? '사용자',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 16,
                          color: i < review.rating
                              ? const Color(0xFFFFB800)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (review.createdAt != null)
                Text(
                  formatRelativeTime(review.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
          // 후기 내용
          if (review.content != null && review.content!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.content!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
