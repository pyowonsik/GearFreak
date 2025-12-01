import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 인증 상태 (Sealed Class 방식)
sealed class AuthState {
  const AuthState();
}

/// 초기 상태
class AuthInitial extends AuthState {
  /// AuthInitial 생성자
  const AuthInitial();
}

/// 로딩 중 상태
class AuthLoading extends AuthState {
  /// AuthLoading 생성자
  const AuthLoading();
}

/// 인증 성공 상태
class AuthAuthenticated extends AuthState {
  /// 사용자 정보
  const AuthAuthenticated(this.user);

  /// 사용자 정보
  final pod.User user;
}

/// 인증 실패 상태
class AuthError extends AuthState {
  /// AuthError 생성자
  ///
  /// [message]는 에러 메시지입니다.
  const AuthError(this.message);

  /// 에러 메시지
  final String message;
}

/// 인증되지 않은 상태
class AuthUnauthenticated extends AuthState {
  /// AuthUnauthenticated 생성자
  const AuthUnauthenticated();
}
