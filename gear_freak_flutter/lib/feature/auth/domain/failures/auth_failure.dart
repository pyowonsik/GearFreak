import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';

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
  const AuthenticationTokenFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

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

/// 회원가입 실패
class SignupFailure extends AuthFailure {
  /// SignupFailure 생성자
  ///
  /// [message]는 실패 메시지입니다.
  /// [exception]는 예외입니다.
  /// [stackTrace]는 스택 트레이스입니다.
  const SignupFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'SignupFailure: $message';
}

/// 현재 사용자 정보 조회 실패
class GetMeFailure extends AuthFailure {
  /// GetMeFailure 생성자
  ///
  /// [message]는 실패 메시지입니다.
  /// [exception]는 예외입니다.
  /// [stackTrace]는 스택 트레이스입니다.
  const GetMeFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'GetMeFailure: $message';
}
