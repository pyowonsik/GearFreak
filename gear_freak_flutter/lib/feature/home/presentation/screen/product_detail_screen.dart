import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../utils/product_enum_helper.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지
            Container(
              width: double.infinity,
              height: 320,
              color: const Color(0xFFF3F4F6),
              child: const Icon(
                Icons.shopping_bag,
                size: 120,
                color: Color(0xFF9CA3AF),
              ),
            ),
            // 상품 정보
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 판매자 정보
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFF3F4F6),
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '판매자 닉네임',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '서울 강남구',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 20),
                  // 상품명
                  const Text(
                    '리프팅 벨트 (사이즈 M) 거의 새것',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 카테고리 및 시간
                  // TODO: 실제 product 데이터를 받아서 표시
                  Row(
                    children: [
                      Text(
                        getProductCategoryLabel(pod.ProductCategory.equipment),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '·',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '5분 전',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 가격
                  const Text(
                    '150,000원',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 24),
                  // 상품 설명
                  const Text(
                    '상품 설명',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '작년에 구매해서 3개월 정도 사용한 리프팅 벨트입니다.\n'
                    '사이즈는 M이고 상태는 거의 새것과 같습니다.\n'
                    '더 이상 사용하지 않아 판매합니다.\n\n'
                    '직거래 환영합니다!',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4B5563),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 16),
                  // 상품 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.remove_red_eye_outlined, '조회 132'),
                      _buildInfoItem(Icons.favorite_border, '찜 12'),
                      _buildInfoItem(Icons.chat_bubble_outline, '채팅 5'),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // 찜하기 버튼
              IconButton(
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                  });
                },
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF6B7280),
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              // 1:1 채팅하기 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/chat/${widget.productId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '1:1 채팅하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
