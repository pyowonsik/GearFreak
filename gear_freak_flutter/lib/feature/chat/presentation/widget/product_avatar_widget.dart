import 'package:chat_group_avatar/group_avatar.dart';
import 'package:flutter/material.dart';

/// 상품 이미지 아바타 위젯
/// Presentation Layer: 재사용 가능한 위젯
class ProductAvatarWidget extends StatelessWidget {
  /// ProductAvatarWidget 생성자
  ///
  /// [productImageUrl]는 상품 이미지 URL입니다. (선택, 제공되면 상품 이미지 표시)
  /// [size]는 아바타 크기입니다. (기본값: 56)
  const ProductAvatarWidget({
    this.productImageUrl,
    this.size = 56,
    super.key,
  });

  /// 상품 이미지 URL (선택)
  final String? productImageUrl;

  /// 아바타 크기
  final double size;

  @override
  Widget build(BuildContext context) {
    // 상품 이미지 URL이 있으면 GroupAvatar로 표시 (하나의 이미지)
    if (productImageUrl != null && productImageUrl!.isNotEmpty) {
      return GroupAvatar(
        imageUrls: [productImageUrl],
        size: size,
        borderColor: Colors.white,
      );
    }

    // 상품 이미지가 없으면 기본 아이콘 표시
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFFF3F4F6),
      child: Icon(
        Icons.shopping_bag,
        color: const Color(0xFF9CA3AF),
        size: size / 2,
      ),
    );
  }
}
