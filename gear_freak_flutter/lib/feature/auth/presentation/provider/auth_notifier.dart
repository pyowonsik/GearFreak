import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/service/fcm_service.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/get_me_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/login_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/login_with_apple_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/login_with_google_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/login_with_kakao_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/signup_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';

/// 인증 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  /// AuthNotifier 생성자
  ///
  /// [getMeUseCase]는 현재 사용자 정보 조회 UseCase 인스턴스입니다.
  /// [loginUseCase]는 로그인 UseCase 인스턴스입니다.
  /// [loginWithGoogleUseCase]는 구글 로그인 UseCase 인스턴스입니다.
  /// [loginWithKakaoUseCase]는 카카오 로그인 UseCase 인스턴스입니다.
  /// [loginWithAppleUseCase]는 애플 로그인 UseCase 인스턴스입니다.
  /// [signupUseCase]는 회원가입 UseCase 인스턴스입니다.
  AuthNotifier(
    this.getMeUseCase,
    this.loginUseCase,
    this.loginWithGoogleUseCase,
    this.loginWithKakaoUseCase,
    this.loginWithAppleUseCase,
    this.signupUseCase,
  ) : super(const AuthInitial()) {
    // 앱 시작 시 세션 확인
    _checkSession();
  }

  /// 현재 사용자 정보 조회 UseCase 인스턴스
  final GetMeUseCase getMeUseCase;

  /// 로그인 UseCase 인스턴스
  final LoginUseCase loginUseCase;

  /// 구글 로그인 UseCase 인스턴스
  final LoginWithGoogleUseCase loginWithGoogleUseCase;

  /// 카카오 로그인 UseCase 인스턴스
  final LoginWithKakaoUseCase loginWithKakaoUseCase;

  /// 애플 로그인 UseCase 인스턴스
  final LoginWithAppleUseCase loginWithAppleUseCase;

  /// 회원가입 UseCase 인스턴스
  final SignupUseCase signupUseCase;

  // ==================== Public Methods (UseCase 호출) ====================

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

    await result.fold(
      (failure) {
        state = AuthError(failure.message);
      },
      (user) async {
        state = AuthAuthenticated(user);
        // FCM 토큰 등록
        await FcmService.instance.initialize();
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

    await result.fold(
      (failure) {
        state = AuthError(failure.message);
      },
      (user) async {
        state = AuthAuthenticated(user);
        // FCM 토큰 등록
        await FcmService.instance.initialize();
      },
    );
  }

  /// 구글 로그인
  Future<void> loginWithGoogle() async {
    state = const AuthLoading();

    final result = await loginWithGoogleUseCase(null);

    await result.fold(
      (failure) {
        state = AuthError(failure.message);
      },
      (user) async {
        state = AuthAuthenticated(user);
        // FCM 토큰 등록
        await FcmService.instance.initialize();
      },
    );
  }

  /// 카카오 로그인
  Future<void> loginWithKakao() async {
    state = const AuthLoading();

    final result = await loginWithKakaoUseCase(null);

    await result.fold(
      (failure) {
        state = AuthError(failure.message);
      },
      (user) async {
        state = AuthAuthenticated(user);
        // FCM 토큰 등록
        await FcmService.instance.initialize();
      },
    );
  }

  /// 애플 로그인
  Future<void> loginWithApple() async {
    state = const AuthLoading();

    final result = await loginWithAppleUseCase(null);

    await result.fold(
      (failure) {
        state = AuthError(failure.message);
      },
      (user) async {
        state = AuthAuthenticated(user);
        // FCM 토큰 등록
        await FcmService.instance.initialize();
      },
    );
  }

  /// 로그아웃
  Future<void> logout() async {
    state = const AuthLoading();

    try {
      // FCM 토큰 삭제
      await FcmService.instance.deleteToken();

      // Repository를 통해 로그아웃 (SessionManager.signOutDevice() 호출)
      await loginUseCase.repo.logout();

      state = const AuthUnauthenticated();
    } catch (e) {
      state = const AuthError('로그아웃에 실패했습니다.');
    }
  }

  // ==================== Public Methods (Service 호출) ====================

  // ==================== Private Helper Methods ====================

  /// 앱 시작 시 세션 확인
  Future<void> _checkSession() async {
    state = const AuthLoading();

    final result = await getMeUseCase(null);

    await result.fold(
      (failure) {
        // 세션이 없거나 만료된 경우
        state = const AuthUnauthenticated();
      },
      (user) async {
        if (user != null) {
          state = AuthAuthenticated(user);
          // 세션 확인 후 FCM 토큰 등록
          await FcmService.instance.initialize();
        } else {
          state = const AuthUnauthenticated();
        }
      },
    );
  }
}
