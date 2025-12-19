import 'package:serverpod/serverpod.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import '../service/auth_service.dart';

/// 인증 엔드포인트
class AuthEndpoint extends Endpoint {
  /// 개발용: 이메일 인증 없이 바로 회원가입
  Future<User> signupWithoutEmailVerification(
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

  /// 구글 로그인 후 User 조회 또는 생성
  /// 클라이언트에서 Serverpod Auth의 google.authenticate()를 호출한 후,
  /// 이 메서드를 호출하여 User 테이블에 사용자를 조회하거나 생성합니다.
  ///
  /// Serverpod Auth가 자동으로 UserInfo를 생성하므로,
  /// 이 메서드는 User 테이블에 사용자를 생성하는 역할만 합니다.
  Future<User> getOrCreateUserAfterGoogleLogin(Session session) async {
    return await AuthService.getOrCreateUserAfterGoogleLogin(session);
  }
}
