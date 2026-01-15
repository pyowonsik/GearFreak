import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 알림 트레이 알림 취소 서비스
/// Android에서 FCM이 자동으로 생성한 알림을 취소하기 위한 서비스입니다.
/// iOS에서는 배지만 업데이트하고, 알림 센터의 알림은 사용자가 직접 삭제해야 합니다.
class NotificationCancelService {
  NotificationCancelService._();

  /// 싱글톤 인스턴스
  static final NotificationCancelService instance =
      NotificationCancelService._();

  /// Method Channel (Android 전용)
  static const MethodChannel _channel = MethodChannel('com.gearfreak/notifications');

  /// 모든 알림 취소 (알림 트레이에서 제거)
  ///
  /// Android: NotificationManager.cancelAll() 호출
  /// iOS: 지원하지 않음 (사용자가 직접 삭제해야 함)
  Future<void> cancelAllNotifications() async {
    if (!Platform.isAndroid) {
      debugPrint('📱 [NotificationCancelService] iOS에서는 알림 취소를 지원하지 않습니다.');
      return;
    }

    try {
      await _channel.invokeMethod('cancelAllNotifications');
      debugPrint('✅ [NotificationCancelService] 모든 알림 취소 완료');
    } on PlatformException catch (e) {
      debugPrint('❌ [NotificationCancelService] 알림 취소 실패: ${e.message}');
    } catch (e) {
      debugPrint('❌ [NotificationCancelService] 알림 취소 실패: $e');
    }
  }

  /// 특정 알림 취소 (ID로 취소)
  ///
  /// [id]는 알림 ID입니다.
  /// [tag]는 알림 태그입니다 (선택사항).
  ///
  /// 참고: FCM이 자동으로 생성한 알림은 ID를 모르기 때문에
  /// 이 메서드보다는 cancelAllNotifications()을 사용하는 것이 좋습니다.
  Future<void> cancelNotification(int id, {String? tag}) async {
    if (!Platform.isAndroid) {
      debugPrint('📱 [NotificationCancelService] iOS에서는 알림 취소를 지원하지 않습니다.');
      return;
    }

    try {
      await _channel.invokeMethod('cancelNotification', {
        'id': id,
        'tag': tag,
      });
      debugPrint('✅ [NotificationCancelService] 알림 취소 완료: id=$id, tag=$tag');
    } on PlatformException catch (e) {
      debugPrint('❌ [NotificationCancelService] 알림 취소 실패: ${e.message}');
    } catch (e) {
      debugPrint('❌ [NotificationCancelService] 알림 취소 실패: $e');
    }
  }
}
