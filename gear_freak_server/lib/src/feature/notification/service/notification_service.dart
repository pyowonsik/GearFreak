import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

/// 알림 서비스
class NotificationService {
  // ==================== Public Methods ====================

  /// 알림 생성
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 수신자 사용자 ID
  /// [notificationType]: 알림 타입
  /// [title]: 알림 제목
  /// [body]: 알림 본문
  /// [data]: 알림 데이터 (딥링크용)
  /// Returns: 생성된 알림 ID
  static Future<int> createNotification({
    required Session session,
    required int userId,
    required NotificationType notificationType,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final now = DateTime.now().toUtc();

      // data를 JSON string으로 변환
      String? dataJson;
      if (data != null) {
        dataJson = jsonEncode(data);
      }

      final notification = Notification(
        userId: userId,
        notificationType: notificationType,
        title: title,
        body: body,
        data: dataJson,
        isRead: false,
        readAt: null,
        createdAt: now,
        updatedAt: now,
      );

      final createdNotification =
          await Notification.db.insertRow(session, notification);

      session.log(
        '[NotificationService] createNotification - success: notificationId=${createdNotification.id}, '
        'userId=$userId, type=$notificationType',
        level: LogLevel.info,
      );

      return createdNotification.id!;
    } catch (e, stackTrace) {
      session.log(
        '[NotificationService] createNotification - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 알림 목록 조회 (페이지네이션)
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 조회할 사용자 ID
  /// [page]: 페이지 번호 (기본값: 1)
  /// [limit]: 페이지당 항목 수 (기본값: 10)
  /// Returns: 알림 목록 응답 DTO (읽지 않은 개수 포함)
  static Future<NotificationListResponseDto> getNotifications({
    required Session session,
    required int userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // 1. 전체 개수 조회
      final totalCount = await Notification.db.count(
        session,
        where: (notification) => notification.userId.equals(userId),
      );

      // 2. 읽지 않은 알림 개수 조회
      final unreadCount = await Notification.db.count(
        session,
        where: (notification) =>
            notification.userId.equals(userId) &
            notification.isRead.equals(false),
      );

      // 3. 페이지네이션 계산
      final offset = (page - 1) * limit;
      final totalPages = (totalCount / limit).ceil();
      final hasMore = page < totalPages;

      // 4. 알림 목록 조회 (최신순)
      final notifications = await Notification.db.find(
        session,
        where: (notification) => notification.userId.equals(userId),
        orderBy: (notification) => notification.createdAt,
        orderDescending: true,
        limit: limit,
        offset: offset,
      );

      // 5. 응답 DTO 생성
      final notificationDtos = <NotificationResponseDto>[];
      for (final notification in notifications) {
        // data JSON 파싱
        Map<String, String>? parsedData;
        if (notification.data != null && notification.data!.isNotEmpty) {
          try {
            final decoded =
                jsonDecode(notification.data!) as Map<String, dynamic>;
            parsedData = decoded.map(
              (key, value) => MapEntry(key, value.toString()),
            );
          } catch (e) {
            session.log(
              '[NotificationService] getNotifications - warning: JSON parse failed - data=${notification.data}, error=$e',
              level: LogLevel.warning,
            );
          }
        }

        notificationDtos.add(
          NotificationResponseDto(
            id: notification.id!,
            notificationType: notification.notificationType,
            title: notification.title,
            body: notification.body,
            data: parsedData,
            isRead: notification.isRead,
            readAt: notification.readAt,
            createdAt: notification.createdAt,
          ),
        );
      }

      return NotificationListResponseDto(
        notifications: notificationDtos,
        pagination: PaginationDto(
          page: page,
          limit: limit,
          totalCount: totalCount,
          hasMore: hasMore,
        ),
        unreadCount: unreadCount,
      );
    } catch (e, stackTrace) {
      session.log(
        '[NotificationService] getNotifications - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 알림 읽음 처리
  ///
  /// [session]: Serverpod 세션
  /// [notificationId]: 읽음 처리할 알림 ID
  /// [userId]: 요청자 ID (권한 확인용)
  /// Returns: true = 성공
  /// Throws: Exception - 알림 없음, 권한 없음
  static Future<bool> markAsRead({
    required Session session,
    required int notificationId,
    required int userId,
  }) async {
    try {
      // 1. 알림 조회
      final notification =
          await Notification.db.findById(session, notificationId);

      if (notification == null) {
        throw Exception('알림을 찾을 수 없습니다.');
      }

      // 2. 권한 확인 (본인의 알림만 읽음 처리 가능)
      if (notification.userId != userId) {
        throw Exception('본인의 알림만 읽음 처리할 수 있습니다.');
      }

      // 3. 이미 읽음 처리된 경우 스킵
      if (notification.isRead) {
        session.log(
          '[NotificationService] markAsRead - info: already read - notificationId=$notificationId',
          level: LogLevel.info,
        );
        return true;
      }

      // 4. 읽음 처리
      final now = DateTime.now().toUtc();
      await Notification.db.updateRow(
        session,
        notification.copyWith(
          isRead: true,
          readAt: now,
          updatedAt: now,
        ),
      );

      session.log(
        '[NotificationService] markAsRead - success: notificationId=$notificationId, userId=$userId',
        level: LogLevel.info,
      );

      return true;
    } catch (e, stackTrace) {
      session.log(
        '[NotificationService] markAsRead - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 알림 삭제
  ///
  /// [session]: Serverpod 세션
  /// [notificationId]: 삭제할 알림 ID
  /// [userId]: 요청자 ID (권한 확인용)
  /// Returns: true = 성공
  /// Throws: Exception - 알림 없음, 권한 없음
  static Future<bool> deleteNotification({
    required Session session,
    required int notificationId,
    required int userId,
  }) async {
    try {
      // 1. 알림 조회
      final notification =
          await Notification.db.findById(session, notificationId);

      if (notification == null) {
        throw Exception('알림을 찾을 수 없습니다.');
      }

      // 2. 권한 확인 (본인의 알림만 삭제 가능)
      if (notification.userId != userId) {
        throw Exception('본인의 알림만 삭제할 수 있습니다.');
      }

      // 3. 알림 삭제
      await Notification.db.deleteRow(session, notification);

      session.log(
        '[NotificationService] deleteNotification - success: notificationId=$notificationId, userId=$userId',
        level: LogLevel.info,
      );

      return true;
    } catch (e, stackTrace) {
      session.log(
        '[NotificationService] deleteNotification - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 읽지 않은 알림 개수 조회
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 조회할 사용자 ID
  /// Returns: 읽지 않은 알림 개수
  static Future<int> getUnreadCount({
    required Session session,
    required int userId,
  }) async {
    try {
      final count = await Notification.db.count(
        session,
        where: (notification) =>
            notification.userId.equals(userId) &
            notification.isRead.equals(false),
      );

      return count;
    } catch (e, stackTrace) {
      session.log(
        '[NotificationService] getUnreadCount - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }

  /// 상품 ID로 후기 관련 알림 삭제
  ///
  /// review_received 타입 알림 중 해당 상품의 알림을 삭제합니다.
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// Returns: 삭제된 알림 개수
  static Future<int> deleteNotificationsByProductId({
    required Session session,
    required int productId,
  }) async {
    try {
      // 1. review_received 타입의 모든 알림 조회
      final notifications = await Notification.db.find(
        session,
        where: (notification) => notification.notificationType
            .equals(NotificationType.review_received),
      );

      if (notifications.isEmpty) {
        return 0;
      }

      // 2. data JSON에서 productId가 일치하는 알림 찾기
      int deletedCount = 0;
      for (final notification in notifications) {
        if (notification.data == null || notification.data!.isEmpty) {
          continue;
        }

        try {
          final decoded =
              jsonDecode(notification.data!) as Map<String, dynamic>;
          final notificationProductId =
              int.tryParse(decoded['productId']?.toString() ?? '');

          if (notificationProductId == productId) {
            await Notification.db.deleteRow(session, notification);
            deletedCount++;
          }
        } catch (e) {
          session.log(
            '[NotificationService] deleteNotificationsByProductId - warning: JSON parse failed (ignored) - data=${notification.data}, error=$e',
            level: LogLevel.warning,
          );
        }
      }

      if (deletedCount > 0) {
        session.log(
          '[NotificationService] deleteNotificationsByProductId - success: productId=$productId, deletedCount=$deletedCount',
          level: LogLevel.info,
        );
      }

      return deletedCount;
    } catch (e, stackTrace) {
      session.log(
        '[NotificationService] deleteNotificationsByProductId - error: $e',
        exception: e,
        stackTrace: stackTrace,
        level: LogLevel.error,
      );
      rethrow;
    }
  }
}
