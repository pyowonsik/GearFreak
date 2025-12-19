import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import 'package:gear_freak_server/src/web/routes/root.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,
  );

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
    '/*',
  );

  // 인증 설정
  auth.AuthConfig.set(
    auth.AuthConfig(
      // Firebase 서비스 계정 키 JSON 파일 경로
      // Firebase ID 토큰 검증에 사용됩니다.
      firebaseServiceAccountKeyJson: 'config/fcm-service-account.json',
      // 이메일로 가입할 때 비밀번호의 최소 길이
      minPasswordLength: 8,
      // 사용자가 사용자 이름을 볼 수 있는지 여부
      userCanEditFullName: true,
      // 사용자 이미지를 저장하는 데 사용되는 형식
      userImageFormat: auth.UserImageType.png,
      // 비밀번호 재설정이 유효한 시간
      passwordResetExpirationTime: const Duration(hours: 24),
    ),
  );

  // Start the server.
  await pod.start();

  // After starting the server, you can register future calls. Future calls are
  // tasks that need to happen in the future, or independently of the request/
  // response cycle. For example, you can use future calls to send emails, or to
  // schedule tasks to be executed at a later time. Future calls are executed in
  // the background. Their schedule is persisted to the database, so you will
  // not lose them if the server is restarted.
}
