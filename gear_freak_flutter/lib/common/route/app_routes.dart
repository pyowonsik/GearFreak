import 'package:gear_freak_flutter/common/route/app_route.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/screen/login_screen.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/screen/signup_screen.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/screen/splash_screen.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/screen/chat_screen.dart';
import 'package:gear_freak_flutter/feature/product/presentation/screen/product_detail_screen.dart';
import 'package:gear_freak_flutter/feature/product/presentation/screen/update_product_screen.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/screen/app_info_screen.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/screen/customer_center_screen.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/screen/edit_profile_screen.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/screen/profile_products_screen.dart';
import 'package:go_router/go_router.dart';

/// 앱의 최상위 라우트 구조를 정의하는 클래스
///
/// 다음과 같은 주요 라우트들로 구성됩니다:
/// - 스플래시 화면 (초기 화면)
/// - 인증 화면 (로그인 및 회원가입)
/// - 메인 쉘 (탭 기반 메인 화면)
/// - 독립적인 전체 화면 라우트들
abstract final class AppRoutes {
  /// 앱의 모든 최상위 라우트 목록
  ///
  /// 이 라우트들은 앱의 기본 네비게이션 구조를 형성합니다.
  /// StatefulShellRoute에 포함된 라우트들과 독립적인 전체 화면 라우트들로 구성됩니다.
  static List<RouteBase> get routes => [
        // 스플래시 화면
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // 로그인 화면
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // 회원가입 화면
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // 메인 화면 (탭 네비게이션) - StatefulShellRoute
        AppRoute.base,

        // 상품 수정 화면
        GoRoute(
          path: '/product/edit/:id',
          name: 'update-product',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return UpdateProductScreen(productId: productId);
          },
        ),

        // 상품 상세 화면
        GoRoute(
          path: '/product/:id',
          name: 'product-detail',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return ProductDetailScreen(productId: productId);
          },
        ),

        // 채팅방 화면
        GoRoute(
          path: '/chat/:id',
          name: 'chat-room',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            final sellerId = state.uri.queryParameters['sellerId'];
            return ChatScreen(
              productId: productId,
              sellerId: sellerId != null ? int.tryParse(sellerId) : null,
            );
          },
        ),

        // 프로필 편집 화면
        GoRoute(
          path: '/profile/edit',
          name: 'edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),

        // 앱 정보 화면
        GoRoute(
          path: '/profile/app-info',
          name: 'app-info',
          builder: (context, state) => const AppInfoScreen(),
        ),

        // 고객센터 화면
        GoRoute(
          path: '/profile/customer-center',
          name: 'customer-center',
          builder: (context, state) => const CustomerCenterScreen(),
        ),

        // 내 상품 관리 화면
        GoRoute(
          path: '/profile/my-products',
          name: 'my-products',
          builder: (context, state) =>
              const ProfileProductsScreen(type: 'myProducts'),
        ),

        // 거래완료 상품 화면
        GoRoute(
          path: '/profile/sold-products',
          name: 'sold-products',
          builder: (context, state) =>
              const ProfileProductsScreen(type: 'mySoldProducts'),
        ),

        // 관심 목록 화면
        GoRoute(
          path: '/profile/my-favorite',
          name: 'my-favorite',
          builder: (context, state) =>
              const ProfileProductsScreen(type: 'myFavorite'),
        ),
      ];
}
