import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';
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

  /// 카카오 로그인 인증
  /// 카카오 Access Token을 받아서 검증하고, UserInfo를 생성/조회한 후 인증 키를 발급합니다.
  Future<AuthenticationResponse> authenticateWithKakao(
    Session session,
    String accessToken,
  ) async {
    return await AuthService.authenticateWithKakao(session, accessToken);
  }

  /// 카카오 로그인 후 User 조회 또는 생성
  /// 클라이언트에서 authenticateWithKakao()를 호출한 후,
  /// 이 메서드를 호출하여 User 테이블에 사용자를 조회하거나 생성합니다.
  Future<User> getOrCreateUserAfterKakaoLogin(Session session) async {
    return await AuthService.getOrCreateUserAfterKakaoLogin(session);
  }

  /// 애플 로그인 후 User 조회 또는 생성
  /// 클라이언트에서 Serverpod Auth의 firebase.authenticate()를 호출한 후,
  /// 이 메서드를 호출하여 User 테이블에 사용자를 조회하거나 생성합니다.
  ///
  /// Serverpod Auth가 자동으로 UserInfo를 생성하므로,
  /// 이 메서드는 User 테이블에 사용자를 생성하는 역할만 합니다.
  Future<User> getOrCreateUserAfterAppleLogin(Session session) async {
    return await AuthService.getOrCreateUserAfterAppleLogin(session);
  }

  /// 네이버 로그인 인증
  /// 네이버 Access Token을 받아서 검증하고, UserInfo를 생성/조회한 후 인증 키를 발급합니다.
  Future<AuthenticationResponse> authenticateWithNaver(
    Session session,
    String accessToken,
  ) async {
    return await AuthService.authenticateWithNaver(session, accessToken);
  }

  /// 네이버 로그인 후 User 조회 또는 생성
  /// 클라이언트에서 authenticateWithNaver()를 호출한 후,
  /// 이 메서드를 호출하여 User 테이블에 사용자를 조회하거나 생성합니다.
  Future<User> getOrCreateUserAfterNaverLogin(Session session) async {
    return await AuthService.getOrCreateUserAfterNaverLogin(session);
  }
}
