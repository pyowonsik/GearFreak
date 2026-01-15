import 'dart:async';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/core/route/router_provider.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/notification/di/notification_providers.dart';
import 'package:gear_freak_flutter/shared/service/deep_link_service.dart';
import 'package:gear_freak_flutter/shared/service/fcm_service.dart';
import 'package:gear_freak_flutter/shared/service/pod_service.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

/// 백그라운드 메시지 핸들러
/// 앱이 백그라운드에서 열렸을 때 FCM이 이 함수를 호출함
/// 주의: 이 함수는 알림을 표시하지 않음 (FCM이 자동으로 표시)
/// 주의: 이 함수는 top-level 함수여야 하며, Riverpod Provider에 접근할 수 없음
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('========================================');
  debugPrint('📱 [백그라운드] FCM 알림 수신');
  debugPrint('메시지 ID: ${message.messageId}');
  debugPrint('제목: ${message.notification?.title}');
  debugPrint('내용: ${message.notification?.body}');
  debugPrint('데이터: ${message.data}');
  debugPrint('========================================');

  // Android: 백그라운드에서 앱 아이콘 배지 업데이트
  // 서버에서 보낸 badge 값을 사용 (iOS는 APNs가 자동 처리)
  try {
    final badgeStr = message.data['badge'];
    if (badgeStr != null) {
      final badge = int.tryParse(badgeStr.toString());
      if (badge != null) {
        await AppBadgePlus.updateBadge(badge);
        debugPrint('📛 [백그라운드] 앱 배지 업데이트: $badge');
      }
    }
  } catch (e) {
    debugPrint('⚠️ [백그라운드] 배지 업데이트 실패: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // .env 파일 로드
  await dotenv.load();

  // 카카오 SDK 초기화
  final kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
  if (kakaoNativeAppKey != null && kakaoNativeAppKey.isNotEmpty) {
    KakaoSdk.init(
      nativeAppKey: kakaoNativeAppKey,
    );
  }

  final baseUrl = dotenv.env['BASE_URL'];

  if (baseUrl == null || baseUrl.isEmpty) {
    throw Exception('BASE_URL is not set in .env file');
  }

  PodService.initialize(baseUrl: baseUrl);

  // SessionManager가 SharedPreferences에서 인증 정보를 읽어올 시간을 줍니다
  // SharedPreferences에서 정보를 읽어오는 것을 기다려야 합니다
  await Future<void>.delayed(const Duration(milliseconds: 200));

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// 앱 메인 위젯
class MyApp extends ConsumerStatefulWidget {
  /// MyApp 생성자
  /// [key]는 위젯의 키입니다.
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  AppLifecycleListener? _lifecycleListener;
  StreamSubscription<RemoteMessage>? _notificationTapSubscription;
  DateTime? _lastUnreadCountRefreshTime;

  /// 읽지 않은 채팅 개수 갱신 (중복 호출 방지)
  void _refreshUnreadCount() {
    if (!mounted) return;

    final now = DateTime.now();
    // 1초 이내 중복 호출 방지
    if (_lastUnreadCountRefreshTime != null &&
        now.difference(_lastUnreadCountRefreshTime!) <
            const Duration(seconds: 1)) {
      debugPrint('⏭️ 읽지 않은 채팅 개수 갱신 스킵 (중복 호출 방지)');
      return;
    }
    _lastUnreadCountRefreshTime = now;
    // ignore: unused_result
    ref.refresh(totalUnreadChatCountProvider);
  }

  /// FCM badge 값으로 앱 배지 업데이트 (공통 로직)
  ///
  /// [badge]: 서버에서 전송한 badge 값 (null이면 로컬 계산)
  /// [source]: 로그용 소스 식별자
  Future<void> _updateBadgeFromFcm(int? badge, {required String source}) async {
    if (!mounted) return;

    if (badge != null) {
      debugPrint('📛 [$source] FCM badge 값으로 즉시 업데이트: $badge');
      await AppBadgePlus.updateBadge(badge);
    } else {
      // badge가 null이면 로컬에서 계산 (+1은 새 알림/메시지)
      debugPrint('⚠️ [$source] FCM badge 값이 null, 로컬에서 계산');
      try {
        final chatCount = await ref.read(totalUnreadChatCountProvider.future);
        final notificationCount =
            await ref.read(totalUnreadNotificationCountProvider.future);
        final localBadge = chatCount + notificationCount + 1;
        debugPrint('📛 [$source] 로컬 계산 badge 업데이트: $localBadge');
        await AppBadgePlus.updateBadge(localBadge);
      } catch (e) {
        debugPrint('⚠️ [$source] 로컬 badge 계산 실패: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 딥링크 서비스 초기화 (라우터가 준비된 후)
    // addPostFrameCallback을 사용하여 첫 프레임 이후 초기화
    // 지연 시간을 최소화하여 초기 딥링크를 빠르게 캡처
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final router = ref.read(routerProvider);
        // 딥링크 서비스 초기화 (초기 딥링크를 PendingDeepLinkService에 저장)
        DeepLinkService.instance.initialize(router);
        // FCM 서비스에 라우터 설정
        FcmService.instance.setRouter(router);
        // FCM 메시지 수신 콜백 설정 (채팅방 목록 탭을 열지 않았을 때)
        // 채팅방 목록 탭을 열면 chat_room_list_page.dart의 콜백이 이 콜백을 덮어씀
        FcmService.instance.setOnMessageReceived((chatRoomId, badge) async {
          // 읽지 않은 채팅 개수 갱신 (BottomNavigationBar Badge 업데이트)
          _refreshUnreadCount();

          // 포그라운드에서 알림 수신 시 배지 업데이트
          await _updateBadgeFromFcm(badge, source: 'Chat');

          // Provider도 갱신 (UI 동기화)
          if (!mounted) return;
          ref
            ..invalidate(totalUnreadChatCountProvider)
            ..invalidate(totalUnreadNotificationCountProvider);
        });
        // FCM 알림 수신 콜백 설정 (review_received 등)
        FcmService.instance.setOnNotificationReceived((badge) async {
          // 포그라운드에서 알림 수신 시 배지 업데이트
          await _updateBadgeFromFcm(badge, source: 'Notification');

          // Provider도 갱신 (UI 동기화)
          if (!mounted) return;
          ref
            ..invalidate(totalUnreadChatCountProvider)
            // ignore: unused_result
            ..refresh(totalUnreadNotificationCountProvider);
        });
        // 앱이 종료된 상태에서 알림 탭으로 시작된 경우 처리
        _handleInitialMessage();
        // 백그라운드→포그라운드 알림 탭 처리 (앱 실행 중)
        _setupBackgroundNotificationHandler(router);
      }
    });

    // 앱 생명주기 감지 (포그라운드 <-> 백그라운드)
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) async {
        if (!mounted) return;

        if (state == AppLifecycleState.resumed) {
          // 백그라운드 → 포그라운드: 새 값 로드 후 배지 업데이트
          debugPrint('📱 앱이 포그라운드로 복귀');
          ref
            ..invalidate(totalUnreadChatCountProvider)
            ..invalidate(totalUnreadNotificationCountProvider);
          await _updateAppBadge();
        } else if (state == AppLifecycleState.paused) {
          // 포그라운드 → 백그라운드: FCM 콜백에서 이미 배지 업데이트됨
          // _updateAppBadge() 호출 시 Provider에서 이전 값을 읽어서 덮어쓸 수 있으므로 제거
          debugPrint('📱 앱이 백그라운드로 이동');
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    _notificationTapSubscription?.cancel();
    DeepLinkService.instance.dispose();
    super.dispose();
  }

  /// 백그라운드→포그라운드 알림 탭 핸들러 설정
  void _setupBackgroundNotificationHandler(GoRouter router) {
    // 기존 구독 취소 (메모리 누수 방지)
    _notificationTapSubscription?.cancel();

    // 앱이 백그라운드에서 알림 탭으로 포그라운드로 전환된 경우
    _notificationTapSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('========================================');
      debugPrint('📱 [백그라운드→포그라운드] FCM 알림으로 앱 열림');
      debugPrint('메시지 ID: ${message.messageId}');
      debugPrint('제목: ${message.notification?.title}');
      debugPrint('내용: ${message.notification?.body}');
      debugPrint('데이터: ${message.data}');
      debugPrint('========================================');

      // 알림 탭 처리 (현재 라우터를 직접 전달)
      if (!mounted) return;
      final currentRouter = ref.read(routerProvider);
      FcmService.instance.handleNotificationTap(
        message,
        router: currentRouter,
      );
    });
  }

  /// 앱이 종료된 상태에서 알림 탭으로 시작된 경우 처리
  Future<void> _handleInitialMessage() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('========================================');
        debugPrint('📱 [앱 시작] FCM 알림으로 앱 시작됨');
        debugPrint('메시지 ID: ${initialMessage.messageId}');
        debugPrint('제목: ${initialMessage.notification?.title}');
        debugPrint('내용: ${initialMessage.notification?.body}');
        debugPrint('데이터: ${initialMessage.data}');
        debugPrint('========================================');

        // 알림 탭 처리 (라우터를 직접 전달)
        final router = ref.read(routerProvider);
        FcmService.instance.handleNotificationTap(
          initialMessage,
          router: router,
        );
      }
    } catch (e) {
      debugPrint('⚠️ 초기 메시지 처리 실패: $e');
    }
  }

  /// 앱 아이콘 배지 업데이트
  Future<void> _updateAppBadge() async {
    try {
      // 읽지 않은 채팅 + 알림 개수 조회 (.future로 값 로딩 완료까지 대기)
      final chatCount = await ref.read(totalUnreadChatCountProvider.future);
      final notificationCount =
          await ref.read(totalUnreadNotificationCountProvider.future);
      final totalCount = chatCount + notificationCount;

      debugPrint(
        '📛 앱 배지 업데이트: $totalCount (채팅: $chatCount, 알림: $notificationCount)',
      );

      // app_badge_plus: 0을 전달하면 배지 제거
      await AppBadgePlus.updateBadge(totalCount);
    } catch (e) {
      debugPrint('⚠️ 배지 업데이트 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '운동은 장비빨',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF10B981),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF1F2937)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2563EB),
          unselectedItemColor: Color(0xFF9CA3AF),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      routerConfig: router,
    );
  }
}
