import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 채팅방 상품 정보 카드 위젯
class ChatProductInfoCardWidget extends StatelessWidget {
  /// ChatProductInfoCardWidget 생성자
  ///
  /// [productName]는 상품명입니다.
  /// [price]는 상품 가격입니다.
  /// [product]는 상품 정보입니다. (이미지 표시용)
  const ChatProductInfoCardWidget({
    required this.productName,
    required this.price,
    this.product,
    super.key,
  });

  /// 상품명
  final String productName;

  /// 상품 가격
  final String price;

  /// 상품 정보 (이미지 표시용)
  final pod.Product? product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: (product?.imageUrls?.isNotEmpty ?? false)
                  ? CachedNetworkImage(
                      imageUrl: product!.imageUrls!.first,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholderFadeInDuration: Duration.zero,
                      memCacheWidth: 72, // 표시 크기보다 약간 크게 (48 * 1.5)
                      memCacheHeight: 72,
                      maxWidthDiskCache: 72,
                      maxHeightDiskCache: 72,
                      useOldImageOnUrlChange: true,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.shopping_bag,
                          size: 24,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.shopping_bag,
                        size: 24,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
