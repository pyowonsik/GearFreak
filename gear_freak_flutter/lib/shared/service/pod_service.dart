import 'package:flutter/foundation.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

/// Serverpod 서비스 싱글톤
/// kobic 프로젝트 스타일의 PodService
class PodService {
  /// PodService 초기화
  /// 앱 시작 시 한 번만 호출해야 합니다.
  factory PodService.initialize({required String baseUrl}) {
    debugPrint('🔌 PodService.initialize: $baseUrl');
    _instance.client = pod.Client(
      baseUrl,
      authenticationKeyManager: FlutterAuthenticationKeyManager(),
      connectionTimeout: const Duration(minutes: 15),
      streamingConnectionTimeout: const Duration(minutes: 20),
    )..connectivityMonitor = FlutterConnectivityMonitor();

    debugPrint('✅ PodService client created');

    _instance.sessionManager = SessionManager(
      caller: _instance.client.modules.auth,
    );

    return _instance;
  }

  /// PodService 생성자
  PodService._();
  static final PodService _instance = PodService._();

  /// PodService 인스턴스
  static PodService get instance => _instance;

  /// Serverpod Client
  late pod.Client client;

  /// SessionManager
  late SessionManager sessionManager;

  /// 이메일 인증 엔드포인트 (편의 getter)
  dynamic get email => client.modules.auth.email;
}
