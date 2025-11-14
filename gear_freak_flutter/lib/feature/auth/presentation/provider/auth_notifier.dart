import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/user.dart';
import '../../domain/usecase/login_usecase.dart';

/// 인증 상태
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// 인증 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;

  AuthNotifier(this.loginUseCase) : super(const AuthState());

  /// 로그인
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );
        return true;
      },
    );
  }

  /// 로그아웃
  Future<void> logout() async {
    // TODO: 로그아웃 로직 구현
    state = const AuthState();
  }
}

