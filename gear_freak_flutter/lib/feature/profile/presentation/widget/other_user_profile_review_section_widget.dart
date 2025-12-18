import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 다른 사용자 프로필 후기 섹션 위젯
class OtherUserProfileReviewSectionWidget extends StatelessWidget {
  /// OtherUserProfileReviewSectionWidget 생성자
  ///
  /// [reviews]는 후기 목록입니다 (최대 3개).
  /// [averageRating]는 평균 평점입니다 (선택).
  /// [reviewCount]는 전체 후기 개수입니다 (선택).
  /// [onViewAllTap]는 전체보기 버튼 클릭 콜백입니다.
  const OtherUserProfileReviewSectionWidget({
    required this.reviews,
    this.averageRating,
    this.reviewCount,
    this.onViewAllTap,
    super.key,
  });

  /// 후기 목록 (최대 3개)
  final List<pod.TransactionReviewResponseDto> reviews;

  /// 평균 평점 (선택)
  final double? averageRating;

  /// 전체 후기 개수 (선택)
  final int? reviewCount;

  /// 전체보기 버튼 클릭 콜백
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '거래 후기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 24,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        averageRating != null
                            ? averageRating!.toStringAsFixed(1)
                            : '0.0',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '/ 5.0',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      if (reviewCount != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          '($reviewCount)',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAllTap,
                child: const Row(
                  children: [
                    Text('전체보기'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '등록된 후기가 없습니다',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          )
        else
          Column(
            children: reviews.map((review) {
              final formattedDate = review.createdAt != null
                  ? '${review.createdAt!.year}.'
                      '${review.createdAt!.month.toString().padLeft(2, '0')}.'
                      '${review.createdAt!.day.toString().padLeft(2, '0')}'
                  : '';

              return Container(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFE5E7EB),
                          backgroundImage:
                              review.reviewerProfileImageUrl != null
                                  ? CachedNetworkImageProvider(
                                      review.reviewerProfileImageUrl!,
                                    )
                                  : null,
                          child: review.reviewerProfileImageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Color(0xFF9CA3AF),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.reviewerNickname ?? '사용자',
                                style: const TextStyle(
                                  fontSize: 15,
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
                                    size: 14,
                                    color: i < review.rating
                                        ? const Color(0xFFFFB800)
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (formattedDate.isNotEmpty)
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                    if (review.content != null &&
                        review.content!.isNotEmpty) ...[
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
            }).toList(),
          ),
      ],
    );
  }
}
