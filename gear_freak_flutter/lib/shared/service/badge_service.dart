import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/notification/di/notification_providers.dart';

/// 앱 아이콘 배지 관리 서비스
/// 채팅과 알림의 읽지 않은 개수를 합산하여 앱 배지를 업데이트합니다.
class BadgeService {
  BadgeService._();

  /// 싱글톤 인스턴스
  static final BadgeService instance = BadgeService._();

  /// 앱 아이콘 배지 업데이트
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// Provider에서 읽지 않은 채팅 + 알림 개수를 조회하여 배지를 업데이트합니다.
  Future<void> updateBadge(Ref ref) async {
    try {
      final chatCount = await ref.read(totalUnreadChatCountProvider.future);
      final notificationCount =
          await ref.read(totalUnreadNotificationCountProvider.future);
      final totalCount = chatCount + notificationCount;

      debugPrint(
        '📛 [BadgeService] 앱 배지 업데이트: $totalCount '
        '(채팅: $chatCount, 알림: $notificationCount)',
      );

      // app_badge_plus: 0을 전달하면 배지 제거
      await AppBadgePlus.updateBadge(totalCount);
    } catch (e) {
      debugPrint('⚠️ [BadgeService] 배지 업데이트 실패: $e');
    }
  }

  /// Provider 무효화 후 앱 아이콘 배지 업데이트
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// 먼저 Provider를 무효화하여 최신 값을 가져온 후 배지를 업데이트합니다.
  Future<void> invalidateAndUpdateBadge(Ref ref) async {
    ref
      ..invalidate(totalUnreadChatCountProvider)
      ..invalidate(totalUnreadNotificationCountProvider);
    await updateBadge(ref);
  }
}
