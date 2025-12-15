import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/route/router_provider.dart';
import 'package:gear_freak_flutter/common/service/deep_link_service.dart';
import 'package:gear_freak_flutter/common/service/fcm_service.dart';
import 'package:gear_freak_flutter/common/service/pod_service.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';

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
  // 백그라운드에서는 Provider에 접근할 수 없으므로
  // 앱이 포그라운드로 돌아올 때 처리됨 (onMessageOpenedApp 또는 getInitialMessage)
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // .env 파일 로드
  await dotenv.load(fileName: '.env');

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
  @override
  void initState() {
    super.initState();
    // 딥링크 서비스 초기화 (라우터가 준비된 후)
    // 여러 프레임을 기다려서 라우터가 완전히 준비될 때까지 대기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          final router = ref.read(routerProvider);
          DeepLinkService.instance.initialize(router);
          // FCM 서비스에 라우터 설정
          FcmService.instance.setRouter(router);
          // FCM 메시지 수신 콜백 설정 (채팅방 정보 갱신)
          FcmService.instance.setOnMessageReceived((chatRoomId) {
            // 채팅방 정보 갱신 (마지막 메시지 조회 및 업데이트)
            ref
                .read(chatRoomListNotifierProvider.notifier)
                .refreshChatRoomInfo(chatRoomId);
          });
          // 앱이 종료된 상태에서 알림 탭으로 시작된 경우 처리
          _handleInitialMessage();
        }
      });
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

        // 알림 탭 처리
        final router = ref.read(routerProvider);
        await FcmService.instance.setRouter(router);
        FcmService.instance.handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('⚠️ 초기 메시지 처리 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '운동은 장비충',
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
