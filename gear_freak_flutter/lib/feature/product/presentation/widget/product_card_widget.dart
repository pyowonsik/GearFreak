import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/core/util/format_utils.dart';
import 'package:gear_freak_flutter/core/util/product_utils.dart';
import 'package:gear_freak_flutter/feature/product/presentation/utils/product_enum_helper.dart';
import 'package:go_router/go_router.dart';

/// 상품 카드 위젯
class ProductCardWidget extends StatelessWidget {
  /// ProductCardWidget 생성자
  ///
  /// [product]는 상품 정보입니다.
  const ProductCardWidget({
    required this.product,
    super.key,
  });

  /// 상품 정보
  final pod.Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/product/${product.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 상품 이미지 또는 플레이스홀더
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: (product.imageUrls?.isNotEmpty ?? false)
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrls!.first,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        placeholderFadeInDuration: Duration.zero,
                        memCacheWidth: 150, // 표시 크기보다 약간 크게 (100 * 1.5)
                        memCacheHeight: 150,
                        maxWidthDiskCache: 150,
                        maxHeightDiskCache: 150,
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
                            size: 48,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.shopping_bag,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${getProductCategoryLabel(product.category)} · '
                      '${getProductLocation(product)} · '
                      '${formatRelativeTime(
                        product.updatedAt ?? product.createdAt,
                      )}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${formatPrice(product.price)}원',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.favoriteCount ?? 0}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.chatCount ?? 0}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
