import 'package:gear_freak_flutter/common/domain/failure/failure.dart';

/// 알림 목록 조회 실패
class GetNotificationsFailure extends Failure {
  /// GetNotificationsFailure 생성자
  const GetNotificationsFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 알림 읽음 처리 실패
class MarkAsReadFailure extends Failure {
  /// MarkAsReadFailure 생성자
  const MarkAsReadFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 알림 삭제 실패
class DeleteNotificationFailure extends Failure {
  /// DeleteNotificationFailure 생성자
  const DeleteNotificationFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 읽지 않은 알림 개수 조회 실패
class GetUnreadCountFailure extends Failure {
  /// GetUnreadCountFailure 생성자
  const GetUnreadCountFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}
