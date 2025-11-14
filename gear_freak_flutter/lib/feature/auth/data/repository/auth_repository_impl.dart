import '../../domain/entity/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 인증 Repository 구현
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl(this.remoteDataSource, this.sharedPreferences);

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await remoteDataSource.login(
      email: email,
      password: password,
    );

    final user = User(
      id: data['id'] as String,
      email: data['email'] as String,
      nickname: data['nickname'] as String?,
      accessToken: data['accessToken'] as String?,
      refreshToken: data['refreshToken'] as String?,
    );

    // 토큰 저장
    if (user.accessToken != null && user.refreshToken != null) {
      await saveTokens(
        accessToken: user.accessToken!,
        refreshToken: user.refreshToken!,
      );
    }

    return user;
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove('access_token');
    await sharedPreferences.remove('refresh_token');
    await sharedPreferences.remove('user_id');
  }

  @override
  Future<User?> getCurrentUser() async {
    final userId = sharedPreferences.getString('user_id');
    final accessToken = sharedPreferences.getString('access_token');

    if (userId == null || accessToken == null) {
      return null;
    }

    // TODO: 서버에서 사용자 정보 조회
    return User(
      id: userId,
      email: '', // TODO: 저장된 이메일 조회
      accessToken: accessToken,
      refreshToken: sharedPreferences.getString('refresh_token'),
    );
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await sharedPreferences.setString('access_token', accessToken);
    await sharedPreferences.setString('refresh_token', refreshToken);
  }
}
