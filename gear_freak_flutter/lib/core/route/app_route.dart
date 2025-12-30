import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/core/route/app_router_page.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/screen/chat_room_list_screen.dart';
import 'package:gear_freak_flutter/feature/product/presentation/screen/create_product_screen.dart';
import 'package:gear_freak_flutter/feature/product/presentation/screen/home_screen.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/screen/profile_screen.dart';
import 'package:gear_freak_flutter/feature/search/presentation/page/search_page.dart';
import 'package:go_router/go_router.dart';

/// 앱의 메인 라우터(탭 기반 네비게이션) 라우트를 정의하는 클래스
///
/// 앱의 주요 탭 구조(홈, 검색, 채팅, 프로필)를 정의하고
/// 각 탭의 상태를 유지하는 StatefulShellRoute를 관리합니다.
abstract class AppRoute {
  /// 브랜치별 네비게이터 키들 (전역 접근 가능)
  /// - homeTabNavigatorKey: 홈 탭 네비게이터 키
  static final GlobalKey<NavigatorState> homeTabNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'home_tab');

  /// - searchTabNavigatorKey: 검색 탭 네비게이터 키
  static final GlobalKey<NavigatorState> searchTabNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'search_tab');

  /// - createTabNavigatorKey: 등록 탭 네비게이터 키
  static final GlobalKey<NavigatorState> createTabNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'create_tab');

  /// - chatTabNavigatorKey: 채팅 탭 네비게이터 키
  static final GlobalKey<NavigatorState> chatTabNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'chat_tab');

  /// - profileTabNavigatorKey: 프로필 탭 네비게이터 키
  static final GlobalKey<NavigatorState> profileTabNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profile_tab');

  /// 모든 브랜치 네비게이터 키 목록 (인덱스 순서대로)
  static List<GlobalKey<NavigatorState>> get branchNavigatorKeys => [
        homeTabNavigatorKey, // 인덱스 0: 홈 탭
        searchTabNavigatorKey, // 인덱스 1: 검색 탭
        createTabNavigatorKey, // 인덱스 2: 등록 탭
        chatTabNavigatorKey, // 인덱스 3: 채팅 탭
        profileTabNavigatorKey, // 인덱스 4: 프로필 탭
      ];

  /// 메인 라우터 라우트 반환
  static RouteBase get base => _getStatefulShellRoute();

  /// StatefulShellRoute 정의 - 탭 간 화면 상태를 유지하는 라우트
  ///
  /// IndexedStack을 사용하여 각 탭의 상태를 유지하며,
  /// 다음 5개의 주요 브랜치(탭)으로 구성됩니다:
  /// - 홈 탭 (인덱스 0)
  /// - 검색 탭 (인덱스 1)
  /// - 등록 탭 (인덱스 2)
  /// - 채팅 탭 (인덱스 3)
  /// - 프로필 탭 (인덱스 4)
  static final RouteBase _statefulShellRoute = StatefulShellRoute.indexedStack(
    branches: [
      // 홈 탭 (인덱스 0)
      StatefulShellBranch(
        initialLocation: '/main/home',
        navigatorKey: homeTabNavigatorKey,
        routes: [
          GoRoute(
            path: '/main/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),

      // 검색 탭 (인덱스 1)
      StatefulShellBranch(
        initialLocation: '/main/search',
        navigatorKey: searchTabNavigatorKey,
        routes: [
          GoRoute(
            path: '/main/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),
        ],
      ),

      // 등록 탭 (인덱스 2)
      StatefulShellBranch(
        initialLocation: '/main/create',
        navigatorKey: createTabNavigatorKey,
        routes: [
          GoRoute(
            path: '/main/create',
            name: 'create-product-tab',
            builder: (context, state) => const CreateProductScreen(),
          ),
        ],
      ),

      // 채팅 탭 (인덱스 3)
      StatefulShellBranch(
        initialLocation: '/main/chat',
        navigatorKey: chatTabNavigatorKey,
        routes: [
          GoRoute(
            path: '/main/chat',
            name: 'chat-list',
            builder: (context, state) => const ChatRoomListScreen(),
          ),
        ],
      ),

      // 프로필 탭 (인덱스 4)
      StatefulShellBranch(
        initialLocation: '/main/profile',
        navigatorKey: profileTabNavigatorKey,
        routes: [
          GoRoute(
            path: '/main/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    builder: (context, state, navigationShell) {
      return AppRouterPage(navigationShell: navigationShell);
    },
  );

  static RouteBase _getStatefulShellRoute() => _statefulShellRoute;
}
