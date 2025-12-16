import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 리뷰 목록 상태
sealed class ReviewListState {
  /// ReviewListState 생성자
  const ReviewListState();
}

/// 초기 상태
class ReviewListInitial extends ReviewListState {
  /// ReviewListInitial 생성자
  const ReviewListInitial();
}

/// 로딩 중
class ReviewListLoading extends ReviewListState {
  /// ReviewListLoading 생성자
  const ReviewListLoading();
}

/// 로딩 완료
class ReviewListLoaded extends ReviewListState {
  /// ReviewListLoaded 생성자
  const ReviewListLoaded({
    required this.reviews,
    required this.pagination,
  });

  /// 후기 목록
  final List<pod.TransactionReviewResponseDto> reviews;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// copyWith 메서드
  ReviewListLoaded copyWith({
    List<pod.TransactionReviewResponseDto>? reviews,
    pod.PaginationDto? pagination,
  }) {
    return ReviewListLoaded(
      reviews: reviews ?? this.reviews,
      pagination: pagination ?? this.pagination,
    );
  }
}

/// 더 불러오는 중
class ReviewListLoadingMore extends ReviewListState {
  /// ReviewListLoadingMore 생성자
  const ReviewListLoadingMore({
    required this.reviews,
    required this.pagination,
  });

  /// 후기 목록
  final List<pod.TransactionReviewResponseDto> reviews;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;
}

/// 에러 상태
class ReviewListError extends ReviewListState {
  /// ReviewListError 생성자
  const ReviewListError(this.message);

  /// 에러 메시지
  final String message;
}
