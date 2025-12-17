import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 알림 목록 상태
sealed class NotificationListState {
  /// NotificationListState 생성자
  const NotificationListState();
}

/// 초기 상태
class NotificationListInitial extends NotificationListState {
  /// NotificationListInitial 생성자
  const NotificationListInitial();
}

/// 로딩 중
class NotificationListLoading extends NotificationListState {
  /// NotificationListLoading 생성자
  const NotificationListLoading();
}

/// 로딩 완료
class NotificationListLoaded extends NotificationListState {
  /// NotificationListLoaded 생성자
  const NotificationListLoaded({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
  });

  /// 알림 목록
  final List<pod.NotificationResponseDto> notifications;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 읽지 않은 알림 개수
  final int unreadCount;

  /// copyWith 메서드
  NotificationListLoaded copyWith({
    List<pod.NotificationResponseDto>? notifications,
    pod.PaginationDto? pagination,
    int? unreadCount,
  }) {
    return NotificationListLoaded(
      notifications: notifications ?? this.notifications,
      pagination: pagination ?? this.pagination,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// 더 불러오는 중
class NotificationListLoadingMore extends NotificationListState {
  /// NotificationListLoadingMore 생성자
  const NotificationListLoadingMore({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
  });

  /// 알림 목록
  final List<pod.NotificationResponseDto> notifications;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 읽지 않은 알림 개수
  final int unreadCount;
}

/// 에러 상태
class NotificationListError extends NotificationListState {
  /// NotificationListError 생성자
  const NotificationListError(this.message);

  /// 에러 메시지
  final String message;
}
