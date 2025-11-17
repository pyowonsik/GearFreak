import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/usecase/signup_usecase.dart';
import '../../../../common/service/pod_service.dart';
import 'auth_state.dart';

/// 인증 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;

  AuthNotifier(this.loginUseCase, this.signupUseCase)
      : super(const AuthInitial()) {
    // 앱 시작 시 세션 확인
    _checkSession();
  }

  /// 앱 시작 시 세션 확인
  Future<void> _checkSession() async {
    state = const AuthLoading();

    try {
      // 서버에서 세션 유효성 확인
      final user = await PodService.instance.client.user.getMe();
      state = AuthAuthenticated(user);
    } catch (e) {
      // 세션이 없거나 만료된 경우
      state = const AuthUnauthenticated();
    }
  }

  /// 회원가입
  Future<void> signup({
    required String userName,
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    final result = await signupUseCase(
      SignupParams(
        userName: userName,
        email: email,
        password: password,
      ),
    );

    result.fold(
      (failure) {
        state = AuthError(failure.message);
      },
      (user) {
        state = AuthAuthenticated(user);
      },
    );
  }

  /// 로그인
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = AuthError(failure.message);
      },
      (user) {
        state = AuthAuthenticated(user);
      },
    );
  }

  /// 로그아웃
  Future<void> logout() async {
    state = const AuthLoading();

    try {
      // Repository를 통해 로그아웃 (SessionManager.signOutDevice() 호출)
      await loginUseCase.repo.logout();

      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError('로그아웃에 실패했습니다.');
    }
  }
}
