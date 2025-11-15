import '../../domain/entity/user.dart';

/// 인증 상태 (Sealed Class 방식)
/// BLoC의 State 추상 클래스와 유사한 패턴
sealed class AuthState {
  const AuthState();
}

/// 초기 상태
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// 로딩 중 상태
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// 인증 성공 상태
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);
}

/// 인증 실패 상태
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}

/// 인증되지 않은 상태
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
