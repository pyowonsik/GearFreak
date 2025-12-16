import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 후기 관리 화면
/// Presentation Layer: UI
class ReviewListScreen extends StatefulWidget {
  /// ReviewListScreen 생성자
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('후기 관리'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF2563EB),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: '받은 후기'),
            Tab(text: '쓴 후기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ReceivedReviewsTab(),
          _WrittenReviewsTab(),
        ],
      ),
    );
  }
}

/// 받은 후기 탭
class _ReceivedReviewsTab extends StatelessWidget {
  const _ReceivedReviewsTab();

  @override
  Widget build(BuildContext context) {
    // 하드코딩 데이터
    final reviews = [
      {
        'reviewerNickname': '김철수',
        'reviewerProfileImage': null,
        'rating': 5,
        'content': '빠른 답변과 친절한 거래 감사합니다. 상품 상태도 좋고 만족스러운 거래였어요!',
        'productName': '나이키 에어맥스 270',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'reviewerNickname': '이영희',
        'reviewerProfileImage': null,
        'rating': 5,
        'content': '깔끔하게 포장해주셔서 감사합니다. 다음에도 또 거래하고 싶어요.',
        'productName': '아디다스 슈퍼스타',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'reviewerNickname': '박민수',
        'reviewerProfileImage': null,
        'rating': 4,
        'content': '좋은 거래였습니다!',
        'productName': '뉴발란스 530',
        'createdAt': DateTime.now().subtract(const Duration(days: 7)),
      },
      {
        'reviewerNickname': '최지우',
        'reviewerProfileImage': null,
        'rating': 5,
        'content': '친절하고 빠른 응대 감사합니다. 상품도 설명과 똑같아요.',
        'productName': '컨버스 척테일러',
        'createdAt': DateTime.now().subtract(const Duration(days: 14)),
      },
    ];

    if (reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Color(0xFFE5E7EB),
            ),
            SizedBox(height: 16),
            Text(
              '받은 후기가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 8,
        color: Color(0xFFF3F4F6),
      ),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _ReviewItemWidget(
          reviewerNickname: review['reviewerNickname'] as String,
          reviewerProfileImage: review['reviewerProfileImage'] as String?,
          rating: review['rating'] as int,
          content: review['content'] as String,
          productName: review['productName'] as String,
          createdAt: review['createdAt'] as DateTime,
        );
      },
    );
  }
}

/// 쓴 후기 탭
class _WrittenReviewsTab extends StatelessWidget {
  const _WrittenReviewsTab();

  @override
  Widget build(BuildContext context) {
    // 하드코딩 데이터
    final reviews = [
      {
        'revieweeNickname': '정다은',
        'revieweeProfileImage': null,
        'rating': 5,
        'content': '믿고 거래할 수 있는 좋은 분이었습니다. 감사합니다!',
        'productName': '아식스 젤카야노',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'revieweeNickname': '강민호',
        'revieweeProfileImage': null,
        'rating': 4,
        'content': '거래 감사합니다.',
        'productName': '반스 올드스쿨',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];

    if (reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note_outlined,
              size: 80,
              color: Color(0xFFE5E7EB),
            ),
            SizedBox(height: 16),
            Text(
              '쓴 후기가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 8,
        color: Color(0xFFF3F4F6),
      ),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _ReviewItemWidget(
          reviewerNickname: review['revieweeNickname'] as String,
          reviewerProfileImage: review['revieweeProfileImage'] as String?,
          rating: review['rating'] as int,
          content: review['content'] as String,
          productName: review['productName'] as String,
          createdAt: review['createdAt'] as DateTime,
        );
      },
    );
  }
}

/// 후기 아이템 위젯
class _ReviewItemWidget extends StatelessWidget {
  const _ReviewItemWidget({
    required this.reviewerNickname,
    required this.rating,
    required this.content,
    required this.productName,
    required this.createdAt,
    this.reviewerProfileImage,
  });

  final String reviewerNickname;
  final String? reviewerProfileImage;
  final int rating;
  final String content;
  final String productName;
  final DateTime createdAt;

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
              // 프로필 이미지
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF3F4F6),
                backgroundImage: reviewerProfileImage != null
                    ? CachedNetworkImageProvider(reviewerProfileImage!)
                    : null,
                child: reviewerProfileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 24,
                        color: Color(0xFF9CA3AF),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // 닉네임 및 날짜
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerNickname,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),

              // 별점
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: index < rating
                        ? const Color(0xFFFFB800)
                        : const Color(0xFFE5E7EB),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 후기 내용
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // 상품명
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks주 전';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months개월 전';
    } else {
      return '${date.year}.${date.month}.${date.day}';
    }
  }
}
