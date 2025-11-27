import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';
import 'package:go_router/go_router.dart';

/// 앱의 인증 상태에 따른 라우트 가드 클래스
///
/// 사용자의 인증 상태에 따라 특정 화면으로의 접근을 제어하고
/// 적절한 리디렉션을 제공합니다.
class AppRouteGuard {
  /// RouteGuard 생성자
  ///
  /// Ref를 주입받아 현재 인증 상태를 확인합니다.
  const AppRouteGuard(this.ref);

  /// Riverpod의 Ref
  final Ref ref;

  /// 현재 경로가 로그인 관련 페이지인지 확인하는 메서드
  bool _checkLoginPage(String matched) {
    return matched == '/login' || matched == '/signup';
  }

  /// 로그인이 필요한 페이지인지 확인하는 메서드
  bool _requiresAuthentication(String path) {
    // 로그인 화면과 스플래시 화면은 인증 불필요
    if (path == '/login' || path == '/signup' || path == '/splash') {
      return false;
    }

    // 그 외 모든 페이지는 인증 필요
    return true;
  }

  /// 인증 가드 메서드
  ///
  /// 정책:
  /// - 초기 상태: 스플래시 화면으로 리디렉션
  /// - 미인증 상태 & 인증 실패 상태:
  ///   - 로그인/회원가입 페이지 접근 시 허용
  ///   - 로그인이 필요한 페이지 접근 시 로그인 페이지로 리디렉션
  ///   - 스플래시 화면에서 미인증 시 로그인 페이지로 이동
  /// - 인증 상태:
  ///   - 로그인/회원가입 또는 스플래시 화면 접근 시 메인 화면으로 리디렉션
  /// - 로딩 상태: 현재 위치 유지 (리디렉션 없음)
  String? guard(BuildContext context, GoRouterState goRouterState) {
    const loginPath = '/login';
    const splashPath = '/splash';
    const homePath = '/main/home';
    final currentPath = goRouterState.matchedLocation;

    final isLoginScreen = _checkLoginPage(currentPath);
    final isSplashScreen = currentPath == splashPath;
    final requiresAuth = _requiresAuthentication(currentPath);

    // AuthNotifier의 현재 상태 확인
    final authState = ref.read(authNotifierProvider);

    debugPrint('🛡️ AppRouteGuard 실행:');
    debugPrint('   - 현재 경로: $currentPath');
    debugPrint('   - 인증 상태: ${authState.runtimeType}');
    debugPrint('   - 로그인 화면: $isLoginScreen');
    debugPrint('   - 스플래시 화면: $isSplashScreen');
    debugPrint('   - 인증 필요: $requiresAuth');

    final redirectTo = switch (authState) {
      // 초기 상태: 스플래시 화면으로 리디렉션
      AuthInitial() => isSplashScreen ? null : splashPath,

      // 로딩 상태: 현재 위치 유지 (리디렉션 없음)
      AuthLoading() => null,

      // 미인증 상태: 선택적 리디렉션
      AuthUnauthenticated() => switch (true) {
          // 로그인/회원가입 페이지 접근 시 허용
          _ when isLoginScreen => null,
          // 스플래시 화면에서 미인증 시 로그인 페이지로 이동
          _ when isSplashScreen => loginPath,
          // 로그인이 필요한 페이지 접근 시 로그인 페이지로 리디렉션 (딥링크 정보 포함)
          _ when requiresAuth => _buildLoginPathWithRedirect(currentPath),
          // 그 외는 허용하지 않음 (인증 필요)
          _ => loginPath,
        },

      // 인증 실패 상태: 미인증과 동일하게 처리
      AuthError() => switch (true) {
          // 로그인/회원가입 페이지 접근 시 허용
          _ when isLoginScreen => null,
          // 스플래시 화면에서 인증 실패 시 로그인 페이지로 이동
          _ when isSplashScreen => loginPath,
          // 로그인이 필요한 페이지 접근 시 로그인 페이지로 리디렉션 (딥링크 정보 포함)
          _ when requiresAuth => _buildLoginPathWithRedirect(currentPath),
          // 그 외는 허용하지 않음 (인증 필요)
          _ => loginPath,
        },

      // 인증 상태: 리디렉션
      AuthAuthenticated() => switch (true) {
          // 로그인/회원가입/스플래시 화면 접근 시 메인으로 리디렉션
          _ when isLoginScreen || isSplashScreen => homePath,
          // 모든 조건 충족 시 현재 경로 유지
          _ => null,
        },
    };

    if (redirectTo != null) {
      debugPrint('🔄 리디렉션: $currentPath → $redirectTo');
    } else {
      debugPrint('✅ 현재 경로 유지: $currentPath');
    }

    return redirectTo;
  }

  /// 로그인 경로에 리다이렉트 정보 추가
  ///
  /// [currentPath]는 현재 경로입니다.
  /// 딥링크로 들어온 경우 로그인 후 원래 페이지로 돌아갈 수 있도록 쿼리 파라미터를 추가합니다.
  String _buildLoginPathWithRedirect(String currentPath) {
    // 스플래시나 로그인 화면이 아닌 경우에만 리다이렉트 정보 추가
    if (currentPath != '/splash' &&
        currentPath != '/login' &&
        currentPath != '/signup') {
      return '/login?redirect=${Uri.encodeComponent(currentPath)}';
    }
    return '/login';
  }
}
