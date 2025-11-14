import '../entity/user.dart';

/// 인증 Repository 인터페이스
abstract class AuthRepository {
  /// 로그인
  Future<User> login({
    required String email,
    required String password,
  });

  /// 로그아웃
  Future<void> logout();

  /// 현재 사용자 조회
  Future<User?> getCurrentUser();

  /// 토큰 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
}

