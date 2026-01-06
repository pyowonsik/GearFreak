import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:gear_freak_flutter/shared/service/pending_deep_link_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 딥링크 서비스
/// 앱의 딥링크를 처리하는 싱글톤 서비스입니다.
/// 앱 시작 시 [initialize]를 호출하여 초기화하고,
/// 앱 종료 시 [dispose]를 호출하여 리소스를 정리합니다.
class DeepLinkService {
  DeepLinkService._();

  /// 딥링크 서비스 인스턴스
  static final instance = DeepLinkService._();

  /// 중복 딥링크 방지를 위한 시간 임계값 (1분)
  static const _duplicateThreshold = Duration(seconds: 5);

  /// SharedPreferences 키
  static const _lastDeepLinkUriKey = 'last_deep_link_uri';
  static const _lastDeepLinkTimeKey = 'last_deep_link_time';

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
      debugPrint('⚠️ Deep link service already initialized');
      return;
    }

    try {
      // Hot restart 시 이전 pending deep link 제거
      PendingDeepLinkService.instance.clear();

      _appLinks = AppLinks();
      _router = router;
      _isInitialized = true;

      // 초기 딥링크 처리 (앱이 딥링크로 시작된 경우)
      await _handleInitialLink();

      // 딥링크 리스너 시작
      _startListening();

      debugPrint('✅ Deep link service initialized successfully');
    } on Exception catch (error, stackTrace) {
      debugPrint('❌ Failed to initialize deep link service: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// 앱 시작 시 초기 딥링크 처리
  ///
  /// 초기 딥링크는 인증이 완료되지 않을 수 있으므로
  /// PendingDeepLinkService에 저장만 하고 바로 라우팅하지 않습니다.
  /// 인증 완료 후 [processPendingDeepLink]를 호출하여 처리합니다.
  Future<void> _handleInitialLink() async {
    if (!_isInitialized || _router == null) {
      debugPrint('⚠️ Deep link service not initialized');
      return;
    }

    try {
      // 앱이 딥링크로 시작되었는지 확인
      final uri = await _appLinks.getInitialLink();
      if (uri == null) {
        return;
      }

      // SharedPreferences에서 마지막 딥링크 확인
      final isDuplicate = await _isDuplicateDeepLink(uri);
      if (isDuplicate) {
        debugPrint('⏭️ Skipping duplicate deep link (within 1min): $uri');
        return;
      }

      // uriLinkStream 중복 처리 방지용
      _initialLinkUri = uri;

      debugPrint('🔗 Initial deep link received: $uri');
      debugPrint('📌 Pending deep link until authentication completes');

      // URL 파싱하여 경로 추출
      final routePath = _parseDeepLinkUrl(uri.toString());
      if (routePath != null) {
        // 딥링크 처리 기록 저장
        await _saveDeepLinkRecord(uri);

        // 인증 완료 후 처리하기 위해 보류
        PendingDeepLinkService.instance.setPendingDeepLink(routePath);
      }
    } on Exception catch (error, stackTrace) {
      debugPrint('❌ Failed to handle initial deep link: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// 중복 딥링크 체크 (SharedPreferences 기반)
  ///
  /// 1분 이내에 동일한 딥링크를 처리했다면 true 반환
  Future<bool> _isDuplicateDeepLink(Uri uri) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUri = prefs.getString(_lastDeepLinkUriKey);
      final lastTime = prefs.getInt(_lastDeepLinkTimeKey);

      if (lastUri == uri.toString() && lastTime != null) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - lastTime;
        if (elapsed < _duplicateThreshold.inMilliseconds) {
          debugPrint('⏱️ Last processed ${elapsed}ms ago');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('⚠️ Failed to check duplicate deep link: $e');
      return false;
    }
  }

  /// 딥링크 처리 기록 저장
  Future<void> _saveDeepLinkRecord(Uri uri) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastDeepLinkUriKey, uri.toString());
      await prefs.setInt(
        _lastDeepLinkTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      debugPrint('💾 Deep link record saved');
    } catch (e) {
      debugPrint('⚠️ Failed to save deep link record: $e');
    }
  }

  /// 딥링크 수신 스트림 시작
  void _startListening() {
    if (!_isInitialized || _router == null) {
      debugPrint('⚠️ Deep link service not initialized');
      return;
    }

    // 이미 구독 중이면 중복 구독 방지
    _subscription?.cancel();

    // 새로운 딥링크 수신 대기
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        // 초기 딥링크와 동일한 URI는 무시 (중복 처리 방지)
        if (_initialLinkUri != null && uri == _initialLinkUri) {
          debugPrint('⏭️ Skipping duplicate initial deep link: $uri');
          _initialLinkUri = null; // 한 번만 체크하고 초기화
          return;
        }

        debugPrint('🔗 Deep link received: $uri');
        _handleDeepLink(uri.toString());
      },
      onError: (Object error) {
        debugPrint('❌ Deep link stream error: $error');
      },
    );

    debugPrint('👂 Deep link stream listening started');
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
      debugPrint('🔍 Parsing deep link: $url');

      final uri = Uri.tryParse(url);
      if (uri == null) {
        debugPrint('❌ Invalid URL format: $url');
        return null;
      }

      debugPrint('🔍 URI parsed:');
      debugPrint('   - scheme: ${uri.scheme}');
      debugPrint('   - host: ${uri.host}');
      debugPrint('   - path: ${uri.path}');
      debugPrint('   - query: ${uri.query}');

      // 카카오 OAuth 딥링크는 카카오 SDK가 자체적으로 처리하므로 무시
      if (uri.scheme.startsWith('kakao') && uri.host == 'oauth') {
        debugPrint('✅ Kakao OAuth deep link, handled by Kakao SDK');
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
        debugPrint('🔍 Custom scheme: routePath = $routePath');
      } else if (uri.scheme == 'https' || uri.scheme == 'http') {
        // HTTPS/HTTP App Links인 경우 (https://gear-freaks.com/product/123)
        routePath = uri.path;
        debugPrint('🔍 HTTPS/HTTP: routePath = $routePath');
      } else {
        debugPrint('❌ Unsupported URL scheme: ${uri.scheme}');
        return null;
      }

      // 경로가 비어있거나 슬래시로 시작하지 않으면 추가
      if (routePath.isEmpty) {
        routePath = '/';
        debugPrint('🔍 Empty path, set to "/"');
      } else if (!routePath.startsWith('/')) {
        routePath = '/$routePath';
        debugPrint('🔍 Added "/" to path: $routePath');
      }

      // 쿼리 파라미터가 있으면 추가
      if (uri.hasQuery) {
        final separator = routePath.contains('?') ? '&' : '?';
        routePath = '$routePath$separator${uri.query}';
        debugPrint('🔍 Query parameters added: $routePath');
      }

      debugPrint('📍 Final route path: $routePath');
      return routePath;
    } on Exception catch (error, stackTrace) {
      debugPrint('❌ Deep link parsing error: $error');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// 딥링크 URL 처리 (앱 실행 중 수신된 딥링크)
  ///
  /// [url]은 딥링크 URL입니다.
  /// 앱이 이미 실행 중일 때 수신된 딥링크는 바로 라우팅합니다.
  Future<void> _handleDeepLink(String url) async {
    if (_router == null) {
      debugPrint('⚠️ GoRouter is not set');
      return;
    }

    final routePath = _parseDeepLinkUrl(url);
    if (routePath == null) {
      debugPrint('⚠️ Deep link parsing failed, aborting navigation');
      return;
    }

    // 앱 실행 중 딥링크는 바로 라우팅
    await _navigateToDeepLink(routePath);
  }

  /// 파싱된 경로로 라우팅 실행
  ///
  /// [routePath]는 파싱된 경로입니다.
  Future<void> _navigateToDeepLink(String routePath) async {
    final router = _router;
    if (router == null) {
      debugPrint('⚠️ GoRouter is not set');
      return;
    }

    try {
      final currentUri = router.routerDelegate.currentConfiguration.uri;
      debugPrint('📍 Current router location: $currentUri');
      debugPrint('🚀 Preparing navigation: $routePath');

      // 라우터가 준비될 때까지 대기
      await _waitForRouterReady();

      // 라우팅 실행
      router.go(routePath);
      debugPrint('✅ Deep link navigation completed: $routePath');
    } catch (e, stackTrace) {
      debugPrint('❌ Navigation failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
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
      debugPrint('🔗 Processing pending deep link: $pendingLink');
      await _navigateToDeepLink(pendingLink);
    }
  }

  /// 딥링크 수신 스트림 중지
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('🛑 Deep link stream stopped');
  }

  /// 리소스 정리
  void dispose() {
    stopListening();
    _isInitialized = false;
    _router = null;
    debugPrint('🗑️ Deep link service disposed');
  }
}
