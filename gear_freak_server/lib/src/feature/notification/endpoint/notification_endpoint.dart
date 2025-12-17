import 'package:gear_freak_server/src/feature/notification/service/notification_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 알림 엔드포인트
class NotificationEndpoint extends Endpoint {
  /// 알림 목록 조회 (페이지네이션)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [page]는 페이지 번호입니다 (기본값: 1).
  /// [limit]는 페이지당 항목 수입니다 (기본값: 10).
  /// 반환: 알림 목록 응답 DTO
  Future<NotificationListResponseDto> getNotifications(
    Session session, {
    int page = 1,
    int limit = 10,
  }) async {
    // 인증 확인 및 User 테이블의 실제 ID 가져오기
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await NotificationService.getNotifications(
      session: session,
      userId: user.id!,
      page: page,
      limit: limit,
    );
  }

  /// 알림 읽음 처리
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [notificationId]는 읽음 처리할 알림 ID입니다.
  /// 반환: 읽음 처리 성공 여부
  Future<bool> markAsRead(
    Session session,
    int notificationId,
  ) async {
    // 인증 확인 및 User 테이블의 실제 ID 가져오기
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await NotificationService.markAsRead(
      session: session,
      notificationId: notificationId,
      userId: user.id!,
    );
  }

  /// 알림 삭제
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [notificationId]는 삭제할 알림 ID입니다.
  /// 반환: 삭제 성공 여부
  Future<bool> deleteNotification(
    Session session,
    int notificationId,
  ) async {
    // 인증 확인 및 User 테이블의 실제 ID 가져오기
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await NotificationService.deleteNotification(
      session: session,
      notificationId: notificationId,
      userId: user.id!,
    );
  }

  /// 읽지 않은 알림 개수 조회
  ///
  /// [session]은 Serverpod 세션입니다.
  /// 반환: 읽지 않은 알림 개수
  Future<int> getUnreadCount(
    Session session,
  ) async {
    // 인증 확인 및 User 테이블의 실제 ID 가져오기
    final user = await UserService.getMe(session);
    if (user.id == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return await NotificationService.getUnreadCount(
      session: session,
      userId: user.id!,
    );
  }
}
