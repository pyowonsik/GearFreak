import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:gear_freak_flutter/shared/service/pending_deep_link_service.dart';
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
  Uri? _initialLinkUri; // 초기 딥링크 URI (중복 처리 방지용)

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
  ///
  /// 초기 딥링크는 인증이 완료되지 않을 수 있으므로
  /// PendingDeepLinkService에 저장만 하고 바로 라우팅하지 않습니다.
  /// 인증 완료 후 [processPendingDeepLink]를 호출하여 처리합니다.
  Future<void> _handleInitialLink() async {
    if (!_isInitialized || _router == null) {
      debugPrint('⚠️ 딥링크 서비스가 초기화되지 않았습니다');
      return;
    }

    try {
      // 앱이 딥링크로 시작되었는지 확인
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        // 초기 딥링크 URI 저장 (중복 처리 방지용)
        _initialLinkUri = uri;

        debugPrint('🔗 초기 딥링크 수신: $uri');
        debugPrint('📌 인증 대기를 위해 딥링크를 보류합니다');

        // URL 파싱하여 경로 추출
        final routePath = _parseDeepLinkUrl(uri.toString());
        if (routePath != null) {
          // 인증 완료 후 처리하기 위해 보류
          PendingDeepLinkService.instance.setPendingDeepLink(routePath);
        }
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
        // 초기 딥링크와 동일한 URI는 무시 (중복 처리 방지)
        if (_initialLinkUri != null && uri == _initialLinkUri) {
          debugPrint('⏭️ 초기 딥링크 중복 수신 무시: $uri');
          _initialLinkUri = null; // 한 번만 체크하고 초기화
          return;
        }

        debugPrint('🔗 딥링크 수신: $uri');
        _handleDeepLink(uri.toString());
      },
      onError: (Object error) {
        debugPrint('❌ 딥링크 수신 오류: $error');
      },
    );

    debugPrint('👂 딥링크 수신 대기 시작');
  }

  /// 딥링크 URL 파싱
  ///
  /// [url]은 딥링크 URL입니다.
  /// 예: https://gear-freaks.com/product/123
  /// 예: gearfreak://product/123
  ///
  /// 파싱된 경로를 반환하거나, 파싱 실패 시 null 반환합니다.
  String? _parseDeepLinkUrl(String url) {
    try {
      debugPrint('🔍 딥링크 파싱 시작: $url');

      final uri = Uri.tryParse(url);
      if (uri == null) {
        debugPrint('❌ 잘못된 URL 형식: $url');
        return null;
      }

      debugPrint('🔍 URI 파싱 결과:');
      debugPrint('   - scheme: ${uri.scheme}');
      debugPrint('   - host: ${uri.host}');
      debugPrint('   - path: ${uri.path}');
      debugPrint('   - query: ${uri.query}');

      // 카카오 OAuth 딥링크는 카카오 SDK가 자체적으로 처리하므로 무시
      if (uri.scheme.startsWith('kakao') && uri.host == 'oauth') {
        debugPrint('✅ 카카오 OAuth 딥링크는 카카오 SDK가 처리합니다. 무시합니다.');
        return null;
      }

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
        return null;
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
      return routePath;
    } on Exception catch (error, stackTrace) {
      debugPrint('❌ 딥링크 파싱 오류: $error');
      debugPrint('❌ 스택 트레이스: $stackTrace');
      return null;
    }
  }

  /// 딥링크 URL 처리 (앱 실행 중 수신된 딥링크)
  ///
  /// [url]은 딥링크 URL입니다.
  /// 앱이 이미 실행 중일 때 수신된 딥링크는 바로 라우팅합니다.
  Future<void> _handleDeepLink(String url) async {
    if (_router == null) {
      debugPrint('⚠️ GoRouter가 설정되지 않았습니다');
      return;
    }

    final routePath = _parseDeepLinkUrl(url);
    if (routePath == null) {
      debugPrint('⚠️ 딥링크 파싱 실패, 라우팅 중단');
      return;
    }

    // 앱 실행 중 딥링크는 바로 라우팅
    await _navigateToDeepLink(routePath);
  }

  /// 파싱된 경로로 라우팅 실행
  ///
  /// [routePath]는 파싱된 경로입니다.
  Future<void> _navigateToDeepLink(String routePath) async {
    if (_router == null) {
      debugPrint('⚠️ GoRouter가 설정되지 않았습니다');
      return;
    }

    debugPrint(
      '📍 현재 라우터 위치: ${_router!.routerDelegate.currentConfiguration.uri}',
    );
    debugPrint('🚀 라우팅 준비: $routePath');

    // 라우터가 준비될 때까지 대기
    await _waitForRouterReady();

    // 라우팅 실행
    _router!.go(routePath);
    debugPrint('✅ 딥링크 라우팅 완료: $routePath');
  }

  /// 라우터가 준비될 때까지 대기
  ///
  /// WidgetsBinding을 사용하여 다음 프레임이 렌더링될 때까지 대기합니다.
  /// 고정된 delay 대신 실제 준비 상태를 확인합니다.
  Future<void> _waitForRouterReady() async {
    // 다음 프레임까지 대기 (위젯 트리가 완전히 빌드될 때까지)
    await WidgetsBinding.instance.endOfFrame;

    // 추가 안전장치: 한 프레임 더 대기
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// 보류 중인 딥링크 처리
  ///
  /// 인증 완료 후 호출하여 보류된 딥링크를 처리합니다.
  Future<void> processPendingDeepLink() async {
    final pendingLink =
        PendingDeepLinkService.instance.consumePendingDeepLink();
    if (pendingLink != null) {
      debugPrint('🔗 보류된 딥링크 처리 시작: $pendingLink');
      await _navigateToDeepLink(pendingLink);
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
