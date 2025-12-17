import 'package:flutter/material.dart';

/// 별점 위젯
/// Presentation Layer: 재사용 가능한 위젯
class StarRatingWidget extends StatelessWidget {
  /// StarRatingWidget 생성자
  ///
  /// [rating]는 현재 평점입니다 (0~5).
  /// [onRatingChanged]는 평점 변경 시 호출되는 콜백입니다.
  /// [starSize]는 별 크기입니다 (기본값: 40).
  /// [allowHalfRating]는 반 별점 허용 여부입니다 (기본값: false).
  const StarRatingWidget({
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 40,
    this.allowHalfRating = false,
    super.key,
  });

  /// 현재 평점 (0~5)
  final double rating;

  /// 평점 변경 시 호출되는 콜백
  final ValueChanged<double> onRatingChanged;

  /// 별 크기
  final double starSize;

  /// 반 별점 허용 여부
  final bool allowHalfRating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            onRatingChanged(starIndex.toDouble());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starIndex <= rating
                  ? Icons.star
                  : starIndex - 0.5 <= rating && allowHalfRating
                      ? Icons.star_half
                      : Icons.star_border,
              size: starSize,
              color: starIndex <= rating
                  ? const Color(0xFFFFB800)
                  : const Color(0xFFE5E7EB),
            ),
          ),
        );
      }),
    );
  }
}
