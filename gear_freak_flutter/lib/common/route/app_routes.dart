import 'package:go_router/go_router.dart';
import 'app_route.dart';
import '../../feature/auth/presentation/screen/splash_screen.dart';
import '../../feature/auth/presentation/screen/login_screen.dart';
import '../../feature/auth/presentation/screen/signup_screen.dart';
import '../../feature/home/presentation/screen/product_detail_screen.dart';
import '../../feature/chat/presentation/screen/chat_room_screen.dart';

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
            final chatId = state.pathParameters['id'] ?? '';
            return ChatRoomScreen(chatId: chatId);
          },
        ),
      ];
}
