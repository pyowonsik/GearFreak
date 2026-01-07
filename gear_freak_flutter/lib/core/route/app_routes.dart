import 'package:gear_freak_flutter/core/route/app_route.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/presentation.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/presentation.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/presentation.dart';
import 'package:gear_freak_flutter/feature/product/presentation/presentation.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/presentation.dart';
import 'package:gear_freak_flutter/feature/review/presentation/presentation.dart';
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
          builder: (context, state) => const SplashPage(),
        ),

        // 로그인 화면
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),

        // 회원가입 화면
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupPage(),
        ),

        // 메인 화면 (탭 네비게이션) - StatefulShellRoute
        AppRoute.base,

        // 상품 수정 화면
        GoRoute(
          path: '/product/edit/:id',
          name: 'update-product',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return UpdateProductPage(productId: productId);
          },
        ),

        // 상품 상세 화면
        GoRoute(
          path: '/product/:id',
          name: 'product-detail',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return ProductDetailPage(productId: productId);
          },
        ),

        // 채팅방 화면
        GoRoute(
          path: '/chat/:id',
          name: 'chat-room',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            final sellerId = state.uri.queryParameters['sellerId'];
            final chatRoomId = state.uri.queryParameters['chatRoomId'];
            return ChatPage(
              productId: productId,
              sellerId: sellerId != null ? int.tryParse(sellerId) : null,
              chatRoomId: chatRoomId != null ? int.tryParse(chatRoomId) : null,
            );
          },
        ),

        // 채팅방 선택 화면
        GoRoute(
          path: '/chat-room-selection/:id',
          name: 'chat-room-selection',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return ChatRoomSelectionPage(
              productId: int.tryParse(productId) ?? 0,
            );
          },
        ),

        // 프로필 편집 화면
        GoRoute(
          path: '/profile/edit',
          name: 'edit-profile',
          builder: (context, state) => const EditProfilePage(),
        ),

        // 앱 정보 화면
        GoRoute(
          path: '/profile/app-info',
          name: 'app-info',
          builder: (context, state) => const AppInfoPage(),
        ),

        // 고객센터 화면
        GoRoute(
          path: '/profile/customer-center',
          name: 'customer-center',
          builder: (context, state) => const CustomerCenterPage(),
        ),

        // 내 상품 관리 화면
        GoRoute(
          path: '/profile/my-products',
          name: 'my-products',
          builder: (context, state) =>
              const ProfileProductsPage(type: 'myProducts'),
        ),

        // 거래완료 상품 화면
        GoRoute(
          path: '/profile/sold-products',
          name: 'sold-products',
          builder: (context, state) =>
              const ProfileProductsPage(type: 'mySoldProducts'),
        ),

        // 관심 목록 화면
        GoRoute(
          path: '/profile/my-favorite',
          name: 'my-favorite',
          builder: (context, state) =>
              const ProfileProductsPage(type: 'myFavorite'),
        ),

        // 후기 관리 화면
        GoRoute(
          path: '/profile/reviews',
          name: 'profile-reviews',
          builder: (context, state) {
            final tabIndex = state.uri.queryParameters['tabIndex'];
            final initialTabIndex =
                tabIndex != null ? int.tryParse(tabIndex)?.clamp(0, 1) ?? 0 : 0;
            return ReviewListPage(initialTabIndex: initialTabIndex);
          },
        ),

        // 다른 사용자의 모든 후기 목록 화면
        GoRoute(
          path: '/profile/user/:userId/reviews',
          name: 'other-user-reviews',
          builder: (context, state) {
            final userId = state.pathParameters['userId'] ?? '';
            return OtherUserReviewListPage(userId: userId);
          },
        ),

        // 다른 사용자의 상품 목록 화면
        GoRoute(
          path: '/profile/user/:userId/products',
          name: 'other-user-products',
          builder: (context, state) {
            final userId = state.pathParameters['userId'] ?? '';
            return OtherUserProductListPage(userId: userId);
          },
        ),

        // 후기 작성 화면
        GoRoute(
          path: '/product/:productId/review/write',
          name: 'write-review',
          builder: (context, state) {
            final productId = state.pathParameters['productId'] ?? '';
            final revieweeId = state.uri.queryParameters['revieweeId'] ??
                state.uri.queryParameters['buyerId'];
            final chatRoomId = state.uri.queryParameters['chatRoomId'];
            final isSellerReview =
                state.uri.queryParameters['isSellerReview'] == 'true';
            return WriteReviewPage(
              productId: int.tryParse(productId) ?? 0,
              revieweeId: int.tryParse(revieweeId ?? '') ?? 0,
              chatRoomId: int.tryParse(chatRoomId ?? '') ?? 0,
              isSellerReview: isSellerReview,
            );
          },
        ),

        // 알림 리스트 화면
        GoRoute(
          path: '/notifications',
          name: 'notification-list',
          builder: (context, state) => const NotificationListPage(),
        ),

        // 이미 작성한 리뷰 화면
        GoRoute(
          path: '/review/already-written',
          name: 'review-already-written',
          builder: (context, state) {
            final reviewType =
                state.uri.queryParameters['reviewType'] ?? 'seller';
            return ReviewAlreadyWrittenPage(reviewType: reviewType);
          },
        ),

        // 다른 사용자 프로필 화면
        GoRoute(
          path: '/profile/user/:userId',
          name: 'other-user-profile',
          builder: (context, state) {
            final userId = state.pathParameters['userId'] ?? '';
            return OtherUserProfilePage(userId: userId);
          },
        ),
      ];
}
