import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/core/route/app_route_guard.dart';
import 'package:gear_freak_flutter/core/route/app_routes.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:go_router/go_router.dart';

/// 앱의 메인 라우터를 관리하는 클래스
///
/// 이 클래스는 앱의 전체 라우팅 시스템을 초기화하고 설정합니다.
/// 인증 상태에 따른 리디렉션, 라우트 감시, 네비게이션 등을 처리합니다.
final routerProvider = Provider<GoRouter>((ref) {
  // AuthNotifier를 watch하여 상태 변경 감지
  ref.watch(authNotifierProvider);

  final routeGuard = AppRouteGuard(ref);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    redirect: routeGuard.guard,
    routes: AppRoutes.routes,
  );
});
