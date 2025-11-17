import '../../../../common/domain/failure/failure.dart';

/// 인증 실패 추상 클래스
abstract class AuthFailure extends Failure {
  /// AuthFailure 생성자
  const AuthFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'AuthFailure: $message';
}

/// 로그인 실패
class LoginFailure extends AuthFailure {
  /// LoginFailure 생성자
  const LoginFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'LoginFailure: $message';
}

/// 인증 토큰 실패
class AuthenticationTokenFailure extends AuthFailure {
  /// AuthenticationTokenFailure 생성자
  const AuthenticationTokenFailure(super.message,
      {super.exception, super.stackTrace});

  @override
  String toString() => 'AuthenticationTokenFailure: $message';
}

/// 로그아웃 실패
class LogoutFailure extends AuthFailure {
  /// LogoutFailure 생성자
  const LogoutFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'LogoutFailure: $message';
}

// 회원가입 실패
class SignupFailure extends AuthFailure {
  /// SignupFailure 생성자
  const SignupFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'SignupFailure: $message';
}
