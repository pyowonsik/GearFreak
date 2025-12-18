import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/utils/format_utils.dart';
import 'package:go_router/go_router.dart';

/// 다른 사용자 프로필 상품 섹션 위젯
class OtherUserProfileProductsSectionWidget extends StatelessWidget {
  /// OtherUserProfileProductsSectionWidget 생성자
  ///
  /// [products]는 상품 목록입니다 (최대 5개).
  /// [onViewAllTap]는 전체보기 버튼 클릭 콜백입니다.
  const OtherUserProfileProductsSectionWidget({
    required this.products,
    this.onViewAllTap,
    super.key,
  });

  /// 상품 목록 (최대 5개)
  final List<pod.Product> products;

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
              const Text(
                '판매중인 상품',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
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
        const SizedBox(height: 12),
        if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '등록된 상품이 없습니다',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final productId = product.id;
                return GestureDetector(
                  onTap: () {
                    if (productId != null) {
                      context.push('/product/$productId');
                    }
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                height: 120,
                                color: const Color(0xFFF3F4F6),
                                child: (product.imageUrls?.isNotEmpty ?? false)
                                    ? CachedNetworkImage(
                                        imageUrl: product.imageUrls!.first,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 120,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                          child: Icon(
                                            Icons.shopping_bag,
                                            size: 40,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.shopping_bag,
                                          size: 40,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                              ),
                              // 판매완료 또는 예약중 오버레이
                              if (product.status == pod.ProductStatus.sold ||
                                  product.status == pod.ProductStatus.reserved)
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    child: Center(
                                      child: Text(
                                        product.status == pod.ProductStatus.sold
                                            ? '판매완료'
                                            : '예약중',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${formatPrice(product.price)}원',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
