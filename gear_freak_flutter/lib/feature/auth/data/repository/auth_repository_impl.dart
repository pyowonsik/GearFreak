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
    // SessionManager.isSignedIn은 로컬 SharedPreferences를 확인하는 것이므로
    // 비동기로 로드되기 전에 false를 반환할 수 있습니다.
    // 따라서 isSignedIn 체크를 제거하고 바로 API 호출 시도
    // 서버에서 인증 키를 검증하므로 실제 인증 상태를 확인할 수 있습니다.
    try {
      // 서버에서 현재 사용자 정보 조회 (User 클래스 반환)
      // 인증 키가 있으면 자동으로 헤더에 포함되어 서버에서 검증됩니다
      final user = await _client.user.getMe();
      return user;
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

  @override
  Future<pod.User> loginWithGoogle() async {
    return remoteDataSource.loginWithGoogle();
  }

  @override
  Future<pod.User> loginWithKakao() async {
    return remoteDataSource.loginWithKakao();
  }

  @override
  Future<pod.User> loginWithApple() async {
    return remoteDataSource.loginWithApple();
  }
}
