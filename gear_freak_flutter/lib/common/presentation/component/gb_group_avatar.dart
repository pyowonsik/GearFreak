import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// 그룹 아바타 위젯
///
/// 참여자 수에 따라 레이아웃이 자동으로 조정됩니다:
/// - 1명: 단일 원형 이미지
/// - 2명: 대각선으로 겹친 2개의 원형 이미지 (top-right & bottom-left)
/// - 3명: 삼각형 패턴으로 배치된 3개의 원형 이미지
/// - 4명 이상: 2x2 그리드로 배치 (최대 4명까지 표시)
class GbGroupAvatar extends StatelessWidget {
  /// GbGroupAvatar 생성자
  ///
  /// [imageUrls]는 표시할 이미지 URL 목록입니다.
  /// [size]는 전체 아바타의 크기입니다. (기본값: 48)
  /// [borderColor]는 테두리 색상입니다. (기본값: Colors.white)
  /// [borderWidth]는 테두리 너비입니다. (기본값: 2.0)
  const GbGroupAvatar({
    required this.imageUrls,
    this.size = 48,
    this.borderColor,
    this.borderWidth = 2.0,
    super.key,
  });

  /// 이미지 URL 목록
  final List<String?> imageUrls;

  /// 전체 아바타의 크기 (bounding box)
  final double size;

  /// 테두리 색상
  final Color? borderColor;

  /// 테두리 너비
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final count = imageUrls.length;
    if (count <= 1) return _single(context);
    if (count == 2) return _twoDiagonal(context);
    if (count == 3) return _triangleThree(context);
    return _grid2x2(context);
  }

  Widget _single(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: _circle(context, imageUrls.firstOrNull, size),
    );
  }

  Widget _twoDiagonal(BuildContext context) {
    final urlBL = imageUrls.elementAtOrNull(0); // bottom-left avatar (on top)
    final urlTR = imageUrls.elementAtOrNull(1); // top-right avatar (under)
    // 48 기준 36px로 비례 계산
    final avatarSize = size * (36.0 / 48.0);

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Render top-right first so it stays under
          Positioned(
            right: 0,
            top: 0,
            child: _circle(context, urlTR, avatarSize),
          ),
          // Then bottom-left on top
          Positioned(
            bottom: 0,
            left: 0,
            child: _circle(context, urlBL, avatarSize),
          ),
        ],
      ),
    );
  }

  Widget _triangleThree(BuildContext context) {
    final urlTop = imageUrls.elementAtOrNull(0);
    final urlBL = imageUrls.elementAtOrNull(1);
    final urlBR = imageUrls.elementAtOrNull(2);
    // 48 기준 36px로 비례 계산
    final avatarSize = size * (36.0 / 48.0);

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: _circle(context, urlBL, avatarSize),
          ),
          // Bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: _circle(context, urlBR, avatarSize),
          ),
          // Top-center
          Positioned(
            left: (size - avatarSize) / 2,
            top: 0,
            child: _circle(context, urlTop, avatarSize),
          ),
        ],
      ),
    );
  }

  Widget _grid2x2(BuildContext context) {
    final urls = imageUrls.take(4).toList(growable: false);
    // 48 기준 24px로 비례 계산
    final cellSize = size * (24.0 / 48.0);
    final gap = (size - (cellSize * 2)) / 3; // 3개의 갭 (양쪽 끝, 중앙)

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          Positioned(
            left: gap,
            top: gap,
            child: _circle(context, urls.elementAtOrNull(0), cellSize),
          ),
          Positioned(
            left: cellSize + 2 * gap,
            top: gap,
            child: _circle(context, urls.elementAtOrNull(1), cellSize),
          ),
          Positioned(
            left: gap,
            top: cellSize + 2 * gap,
            child: _circle(context, urls.elementAtOrNull(2), cellSize),
          ),
          Positioned(
            left: cellSize + 2 * gap,
            top: cellSize + 2 * gap,
            child: _circle(context, urls.elementAtOrNull(3), cellSize),
          ),
        ],
      ),
    );
  }

  Widget _circle(BuildContext context, String? url, double diameter) {
    final border = borderColor ?? Colors.white;
    const bgColor = Color(0xFFF3F4F6); // 배경색
    const iconColor = Color(0xFF9CA3AF); // 아이콘 색상

    return (url != null && url.isNotEmpty)
        ? CachedNetworkImage(
            errorWidget: (context, _, __) =>
                _placeholder(diameter, border, bgColor, iconColor),
            imageBuilder: (context, provider) => Container(
              decoration: BoxDecoration(
                border: Border.all(color: border, width: borderWidth),
                color: bgColor,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: provider,
                ),
                shape: BoxShape.circle,
              ),
              height: diameter,
              width: diameter,
            ),
            imageUrl: url,
            memCacheHeight:
                (diameter * MediaQuery.devicePixelRatioOf(context)).round(),
            memCacheWidth:
                (diameter * MediaQuery.devicePixelRatioOf(context)).round(),
          )
        : _placeholder(diameter, border, bgColor, iconColor);
  }

  Widget _placeholder(
    double diameter,
    Color border,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: border,
          width: borderWidth,
        ),
        color: bgColor,
        shape: BoxShape.circle,
      ),
      height: diameter,
      width: diameter,
      child: Icon(
        Icons.person,
        size: diameter * 0.5,
        color: iconColor,
      ),
    );
  }
}
