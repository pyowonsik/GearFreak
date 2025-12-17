import 'package:flutter/material.dart';

/// 다른 사용자 프로필 후기 섹션 위젯
class OtherUserProfileReviewSectionWidget extends StatelessWidget {
  /// OtherUserProfileReviewSectionWidget 생성자
  ///
  /// [onViewAllTap]는 전체보기 버튼 클릭 콜백입니다.
  const OtherUserProfileReviewSectionWidget({
    this.onViewAllTap,
    super.key,
  });

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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '거래 후기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 24, color: Color(0xFFFFB800)),
                      SizedBox(width: 6),
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '/ 5.0',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
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
        ...List.generate(3, (index) {
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
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFE5E7EB),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '구매자${index + 1}',
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
                              (i) => const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFFFFB800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '2024.01.15',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '친절하고 빠른 거래 감사합니다! 상품 상태도 설명대로 좋았어요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

