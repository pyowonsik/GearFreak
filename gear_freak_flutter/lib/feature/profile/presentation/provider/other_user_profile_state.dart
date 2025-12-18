import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 다른 사용자 프로필 상태
sealed class OtherUserProfileState {
  /// OtherUserProfileState 생성자
  const OtherUserProfileState();
}

/// 초기 상태
class OtherUserProfileInitial extends OtherUserProfileState {
  /// OtherUserProfileInitial 생성자
  const OtherUserProfileInitial();
}

/// 로딩 중
class OtherUserProfileLoading extends OtherUserProfileState {
  /// OtherUserProfileLoading 생성자
  const OtherUserProfileLoading();
}

/// 로딩 완료
class OtherUserProfileLoaded extends OtherUserProfileState {
  /// OtherUserProfileLoaded 생성자
  const OtherUserProfileLoaded({
    required this.user,
    this.stats,
    this.reviews,
    this.averageRating,
    this.products,
  });

  /// 사용자 정보
  final pod.User user;

  /// 상품 통계 정보 (선택)
  final pod.ProductStatsDto? stats;

  /// 후기 목록 (선택, 최대 3개)
  final List<pod.TransactionReviewResponseDto>? reviews;

  /// 평균 평점 (선택)
  final double? averageRating;

  /// 상품 목록 (선택, 최대 5개)
  final List<pod.Product>? products;

  /// copyWith 메서드
  OtherUserProfileLoaded copyWith({
    pod.User? user,
    pod.ProductStatsDto? stats,
    List<pod.TransactionReviewResponseDto>? reviews,
    double? averageRating,
    List<pod.Product>? products,
    bool clearReviews = false,
    bool clearProducts = false,
  }) {
    // reviews 처리: clearReviews가 true면 null, 아니면 전달된 값 사용 (null이면 기존 값 유지)
    final updatedReviews = clearReviews ? null : (reviews ?? this.reviews);

    // products 처리: clearProducts가 true면 null, 아니면 전달된 값 사용 (null이면 기존 값 유지)
    final updatedProducts = clearProducts ? null : (products ?? this.products);

    return OtherUserProfileLoaded(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      reviews: updatedReviews,
      averageRating: averageRating ?? this.averageRating,
      products: updatedProducts,
    );
  }
}

/// 에러 상태
class OtherUserProfileError extends OtherUserProfileState {
  /// OtherUserProfileError 생성자
  const OtherUserProfileError(this.message);

  /// 에러 메시지
  final String message;
}
