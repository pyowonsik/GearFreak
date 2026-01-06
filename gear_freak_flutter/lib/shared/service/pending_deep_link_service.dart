import 'package:flutter/foundation.dart';

/// 보류 중인 딥링크를 관리하는 싱글톤 서비스
///
/// 앱이 딥링크로 시작되었지만 아직 인증이 완료되지 않은 경우,
/// 딥링크를 보류했다가 인증 완료 후 처리합니다.
///
/// 사용 흐름:
/// 1. 앱이 딥링크로 시작됨
/// 2. DeepLinkService가 딥링크 감지
/// 3. 인증 상태 확인 중이면 PendingDeepLinkService에 저장
/// 4. 인증 완료 후 저장된 딥링크로 라우팅
class PendingDeepLinkService {
  PendingDeepLinkService._();

  /// PendingDeepLinkService 인스턴스
  static final instance = PendingDeepLinkService._();

  /// TTL (Time To Live) - 5분
  static const _ttl = Duration(minutes: 5);

  String? _pendingDeepLink;
  DateTime? _pendingDeepLinkTimestamp;

  /// 보류 중인 딥링크가 있는지 확인
  bool get hasPendingDeepLink => pendingDeepLink != null;

  /// 보류 중인 딥링크 경로
  ///
  /// TTL이 초과된 경우 자동으로 null 반환
  String? get pendingDeepLink {
    if (_pendingDeepLink != null && _pendingDeepLinkTimestamp != null) {
      final elapsed = DateTime.now().difference(_pendingDeepLinkTimestamp!);
      if (elapsed > _ttl) {
        debugPrint(
          '⏰ Pending deep link expired (${elapsed.inMinutes} minutes elapsed)',
        );
        clear();
        return null;
      }
    }
    return _pendingDeepLink;
  }

  /// 딥링크 저장
  ///
  /// [routePath]는 GoRouter에서 사용할 경로입니다.
  /// 예: /product/123, /chat/456?sellerId=789
  void setPendingDeepLink(String routePath) {
    _pendingDeepLink = routePath;
    _pendingDeepLinkTimestamp = DateTime.now();
    debugPrint('📌 Pending deep link saved: $routePath');
  }

  /// 보류 중인 딥링크 가져오고 초기화
  ///
  /// 딥링크를 반환하고 내부 상태를 초기화합니다.
  /// 한 번만 사용되도록 보장합니다.
  String? consumePendingDeepLink() {
    final link = pendingDeepLink; // getter를 통해 TTL 체크
    if (link != null) {
      debugPrint('✅ Consuming pending deep link: $link');
      _pendingDeepLink = null;
      _pendingDeepLinkTimestamp = null;
    }
    return link;
  }

  /// 보류 중인 딥링크 초기화
  void clear() {
    if (_pendingDeepLink != null) {
      debugPrint('🗑️ Clearing pending deep link: $_pendingDeepLink');
      _pendingDeepLink = null;
      _pendingDeepLinkTimestamp = null;
    }
  }
}
