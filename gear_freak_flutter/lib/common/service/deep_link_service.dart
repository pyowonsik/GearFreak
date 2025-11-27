import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// 딥링크 서비스
/// 앱의 딥링크를 처리하는 싱글톤 서비스입니다.
/// 앱 시작 시 [initialize]를 호출하여 초기화하고,
/// 앱 종료 시 [dispose]를 호출하여 리소스를 정리합니다.
class DeepLinkService {
  DeepLinkService._();

  /// 딥링크 서비스 인스턴스
  static final instance = DeepLinkService._();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  bool _isInitialized = false;
  GoRouter? _router;

  /// 서비스 초기화
  ///
  /// [router]는 GoRouter 인스턴스입니다.
  Future<void> initialize(GoRouter router) async {
    if (_isInitialized) {
      debugPrint('⚠️ 딥링크 서비스가 이미 초기화되어 있습니다');
      return;
    }

    try {
      _appLinks = AppLinks();
      _router = router;
      _isInitialized = true;

      // 초기 딥링크 처리 (앱이 딥링크로 시작된 경우)
      await _handleInitialLink();

      // 딥링크 리스너 시작
      _startListening();

      debugPrint('✅ 딥링크 서비스 초기화 완료');
    } on Exception catch (error, stackTrace) {
      debugPrint('❌ 딥링크 서비스 초기화 실패: $error');
      debugPrint('❌ 스택 트레이스: $stackTrace');
    }
  }

  /// 앱 시작 시 초기 딥링크 처리
  Future<void> _handleInitialLink() async {
    if (!_isInitialized || _router == null) {
      debugPrint('⚠️ 딥링크 서비스가 초기화되지 않았습니다');
      return;
    }

    try {
      // 앱이 딥링크로 시작되었는지 확인
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        debugPrint('🔗 초기 딥링크 수신: $uri');
        _handleDeepLink(uri.toString());
      }
    } on Exception catch (error, stackTrace) {
      debugPrint('❌ 초기 딥링크 처리 실패: $error');
      debugPrint('❌ 스택 트레이스: $stackTrace');
    }
  }

  /// 딥링크 수신 스트림 시작
  void _startListening() {
    if (!_isInitialized || _router == null) {
      debugPrint('⚠️ 딥링크 서비스가 초기화되지 않았습니다');
      return;
    }

    // 이미 구독 중이면 중복 구독 방지
    _subscription?.cancel();

    // 새로운 딥링크 수신 대기
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('🔗 딥링크 수신: $uri');
        _handleDeepLink(uri.toString());
      },
      onError: (Object error) {
        debugPrint('❌ 딥링크 수신 오류: $error');
      },
    );

    debugPrint('👂 딥링크 수신 대기 시작');
  }

  /// 딥링크 URL 처리
  ///
  /// [url]은 딥링크 URL입니다.
  /// 예: https://gear-freaks.com/product/123
  /// 예: gearfreak://product/123
  void _handleDeepLink(String url) {
    if (_router == null) {
      debugPrint('⚠️ GoRouter가 설정되지 않았습니다');
      return;
    }

    try {
      debugPrint('🔍 딥링크 파싱 시작: $url');

      final uri = Uri.tryParse(url);
      if (uri == null) {
        debugPrint('❌ 잘못된 URL 형식: $url');
        return;
      }

      debugPrint('🔍 URI 파싱 결과:');
      debugPrint('   - scheme: ${uri.scheme}');
      debugPrint('   - host: ${uri.host}');
      debugPrint('   - path: ${uri.path}');
      debugPrint('   - query: ${uri.query}');

      // URL에서 경로 추출
      String routePath;

      // Custom Scheme인 경우 (gearfreak://product/123)
      if (uri.scheme == 'gearfreak' || uri.scheme == 'gear-freaks') {
        // host가 있으면 경로에 포함, 없으면 path만 사용
        if (uri.host.isNotEmpty) {
          routePath = '/${uri.host}${uri.path}';
        } else {
          routePath = uri.path;
        }
        debugPrint('🔍 Custom Scheme 처리: routePath = $routePath');
      } else if (uri.scheme == 'https' || uri.scheme == 'http') {
        // HTTPS/HTTP App Links인 경우 (https://gear-freaks.com/product/123)
        routePath = uri.path;
        debugPrint('🔍 HTTPS/HTTP 처리: routePath = $routePath');
      } else {
        debugPrint('❌ 지원하지 않는 URL 스킴: ${uri.scheme}');
        return;
      }

      // 경로가 비어있거나 슬래시로 시작하지 않으면 추가
      if (routePath.isEmpty) {
        routePath = '/';
        debugPrint('🔍 경로가 비어있어서 "/"로 설정');
      } else if (!routePath.startsWith('/')) {
        routePath = '/$routePath';
        debugPrint('🔍 경로에 "/" 추가: $routePath');
      }

      // 쿼리 파라미터가 있으면 추가
      if (uri.hasQuery) {
        final separator = routePath.contains('?') ? '&' : '?';
        routePath = '$routePath$separator${uri.query}';
        debugPrint('🔍 쿼리 파라미터 추가: $routePath');
      }

      debugPrint('📍 최종 딥링크 경로: $routePath');
      debugPrint(
          '📍 현재 라우터 위치: ${_router!.routerDelegate.currentConfiguration.uri}');

      // 라우팅 실행 (약간의 지연을 두어 라우터가 준비될 시간을 줌)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_router != null) {
          // 파싱된 경로로 라우팅
          debugPrint('🚀 라우팅 실행: $routePath');
          _router!.go(routePath);
          debugPrint('✅ 딥링크 라우팅 완료: $routePath');
        }
      });
    } on Exception catch (error, stackTrace) {
      debugPrint('❌ 딥링크 처리 오류: $error');
      debugPrint('❌ 스택 트레이스: $stackTrace');
    }
  }

  /// 딥링크 수신 스트림 중지
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('🛑 딥링크 수신 대기 중지');
  }

  /// 리소스 정리
  void dispose() {
    stopListening();
    _isInitialized = false;
    _router = null;
    debugPrint('🗑️ 딥링크 서비스 종료');
  }
}
