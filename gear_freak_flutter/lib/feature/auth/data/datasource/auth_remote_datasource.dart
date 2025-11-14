import 'package:gear_freak_client/gear_freak_client.dart';

/// 인증 원격 데이터 소스
class AuthRemoteDataSource {
  final Client client;

  AuthRemoteDataSource(this.client);

  /// 로그인 API 호출
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // TODO: Serverpod 엔드포인트 호출
    // 예시: return await client.auth.login(email: email, password: password);

    // 임시 더미 데이터
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

    return {
      'id': 'user_1',
      'email': email,
      'nickname': '사용자',
      'accessToken': 'dummy_access_token',
      'refreshToken': 'dummy_refresh_token',
    };
  }
}
