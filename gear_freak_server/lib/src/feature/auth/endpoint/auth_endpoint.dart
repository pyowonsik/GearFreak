import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';
import '../service/auth_service.dart';

/// 인증 엔드포인트
class AuthEndpoint extends Endpoint {
  /// 개발용: 이메일 인증 없이 바로 회원가입
  Future<UserInfo> signupWithoutEmailVerification(
    Session session, {
    required String userName,
    required String email,
    required String password,
  }) async {
    return await AuthService.signupWithoutEmailVerification(
      session,
      userName: userName,
      email: email,
      password: password,
    );
  }
}
