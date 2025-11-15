import '../../domain/entity/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import 'package:gear_freak_client/gear_freak_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

/// 인증 Repository 구현
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final Client client;
  final SessionManager sessionManager;

  AuthRepositoryImpl(this.remoteDataSource, this.client, this.sessionManager);

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await remoteDataSource.login(
      email: email,
      password: password,
    );

    // Serverpod SessionManager가 자동으로 인증 키를 관리하므로
    // 별도로 토큰을 저장할 필요 없음
    final user = User(
      id: data['id']?.toString() ?? '',
      email: data['email'] as String? ?? email,
      nickname: data['userName'] as String?,
    );

    return user;
  }

  @override
  Future<void> logout() async {
    // Serverpod SessionManager를 통해 로그아웃
    await sessionManager.signOutDevice();
  }

  @override
  Future<User?> getMe() async {
    // Serverpod SessionManager를 통해 현재 로그인 상태 확인
    if (!sessionManager.isSignedIn) {
      return null;
    }

    try {
      // 서버에서 현재 사용자 정보 조회
      final userInfo = await client.user.getMe();

      return User(
        id: userInfo.id?.toString() ?? '',
        email: userInfo.email ?? '',
        nickname: userInfo.userName,
      );
    } catch (e) {
      // 로그인 상태가 아니거나 오류 발생 시 null 반환
      return null;
    }
  }

  @override
  Future<User> signup({
    required String userName,
    required String email,
    required String password,
  }) async {
    final data = await remoteDataSource.signup(
      userName: userName,
      email: email,
      password: password,
    );

    final user = User(
      id: data['id']?.toString() ?? '',
      email: data['email'] as String? ?? email,
      nickname: data['userName'] as String? ?? userName,
    );

    return user;
  }
}
