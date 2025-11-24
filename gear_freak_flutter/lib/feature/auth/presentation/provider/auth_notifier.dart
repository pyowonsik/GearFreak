import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/service/pod_service.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/login_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/signup_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';

/// 인증 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  /// AuthNotifier 생성자
  ///
  /// [loginUseCase]는 로그인 UseCase 인스턴스입니다.
  /// [signupUseCase]는 회원가입 UseCase 인스턴스입니다.
  AuthNotifier(this.loginUseCase, this.signupUseCase)
      : super(const AuthInitial()) {
    // 앱 시작 시 세션 확인
    _checkSession();
  }

  /// 로그인 UseCase 인스턴스
  final LoginUseCase loginUseCase;

  /// 회원가입 UseCase 인스턴스
  final SignupUseCase signupUseCase;

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
      state = const AuthError('로그아웃에 실패했습니다.');
    }
  }
}
