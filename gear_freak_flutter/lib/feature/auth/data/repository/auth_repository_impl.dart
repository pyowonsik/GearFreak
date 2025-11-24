import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';
import 'package:gear_freak_flutter/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/auth/domain/repository/auth_repository.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

/// 인증 Repository 구현
class AuthRepositoryImpl implements AuthRepository {
  /// AuthRepositoryImpl 생성자
  ///
  /// [remoteDataSource]는 인증 원격 데이터 소스입니다.
  const AuthRepositoryImpl(this.remoteDataSource);

  /// 인증 원격 데이터 소스
  final AuthRemoteDataSource remoteDataSource;

  pod.Client get _client => PodService.instance.client;
  SessionManager get _sessionManager => PodService.instance.sessionManager;

  @override
  Future<pod.User> login({
    required String email,
    required String password,
  }) async {
    // Serverpod SessionManager가 자동으로 인증 키를 관리하므로
    // 별도로 토큰을 저장할 필요 없음
    return remoteDataSource.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    // Serverpod SessionManager를 통해 로그아웃
    await _sessionManager.signOutDevice();
  }

  @override
  Future<pod.User?> getMe() async {
    // Serverpod SessionManager를 통해 현재 로그인 상태 확인
    if (!_sessionManager.isSignedIn) {
      return null;
    }

    try {
      // 서버에서 현재 사용자 정보 조회 (User 클래스 반환)
      return await _client.user.getMe();
    } catch (e) {
      // 로그인 상태가 아니거나 오류 발생 시 null 반환
      return null;
    }
  }

  @override
  Future<pod.User> signup({
    required String userName,
    required String email,
    required String password,
  }) async {
    return remoteDataSource.signup(
      userName: userName,
      email: email,
      password: password,
    );
  }
}
