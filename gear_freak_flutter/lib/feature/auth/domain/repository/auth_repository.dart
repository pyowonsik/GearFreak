import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 인증 Repository 인터페이스
abstract class AuthRepository {
  /// 로그인
  Future<pod.User> login({
    required String email,
    required String password,
  });

  /// 로그아웃
  Future<void> logout();

  /// 현재 사용자 조회
  Future<pod.User?> getMe();

  /// 회원가입
  Future<pod.User> signup({
    required String userName,
    required String email,
    required String password,
  });

  /// 구글 로그인
  Future<pod.User> loginWithGoogle();

  /// 카카오 로그인
  Future<pod.User> loginWithKakao();

  /// 네이버 로그인
  Future<pod.User> loginWithNaver();

  /// 애플 로그인
  Future<pod.User> loginWithApple();
}
