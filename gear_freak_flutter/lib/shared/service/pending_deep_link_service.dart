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

  String? _pendingDeepLink;

  /// 보류 중인 딥링크가 있는지 확인
  bool get hasPendingDeepLink => _pendingDeepLink != null;

  /// 보류 중인 딥링크 경로
  String? get pendingDeepLink => _pendingDeepLink;

  /// 딥링크 저장
  ///
  /// [routePath]는 GoRouter에서 사용할 경로입니다.
  /// 예: /product/123, /chat/456?sellerId=789
  void setPendingDeepLink(String routePath) {
    _pendingDeepLink = routePath;
    debugPrint('📌 보류 중인 딥링크 저장: $routePath');
  }

  /// 보류 중인 딥링크 가져오고 초기화
  ///
  /// 딥링크를 반환하고 내부 상태를 초기화합니다.
  /// 한 번만 사용되도록 보장합니다.
  String? consumePendingDeepLink() {
    final link = _pendingDeepLink;
    if (link != null) {
      debugPrint('✅ 보류 중인 딥링크 처리: $link');
      _pendingDeepLink = null;
    }
    return link;
  }

  /// 보류 중인 딥링크 초기화
  void clear() {
    if (_pendingDeepLink != null) {
      debugPrint('🗑️ 보류 중인 딥링크 삭제: $_pendingDeepLink');
      _pendingDeepLink = null;
    }
  }
}
