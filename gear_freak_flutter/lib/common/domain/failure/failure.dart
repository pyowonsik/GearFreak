/// 실패를 나타내는 추상 클래스
abstract class Failure {
  /// Failure 생성자
  ///
  /// [message]은 실패 메시지입니다.
  /// [exception]은 예외입니다.
  /// [stackTrace]은 스택 트레이스입니다.
  const Failure(
    this.message, {
    this.exception,
    this.stackTrace,
  });

  /// 예상치 못한 오류
  factory Failure.unexpected({
    required String message,
    Exception? exception,
  }) {
    return UnexpectedFailure(message, exception: exception);
  }

  /// 네트워크 오류
  factory Failure.network(String message, {Exception? exception}) {
    return NetworkFailure(message, exception: exception);
  }

  /// 서버 오류
  factory Failure.server(String message, {Exception? exception}) {
    return ServerFailure(message, exception: exception);
  }

  /// 인증 오류
  factory Failure.authentication(String message, {Exception? exception}) {
    return AuthenticationFailure(message, exception: exception);
  }

  /// 메시지
  final String message;

  /// 예외
  final Exception? exception;

  /// 스택 트레이스
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

/// 예상치 못한 오류
class UnexpectedFailure extends Failure {
  /// UnexpectedFailure 생성자
  /// [message]은 실패 메시지입니다.
  /// [exception]은 예외입니다.
  /// [stackTrace]은 스택 트레이스입니다.
  const UnexpectedFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 네트워크 오류
class NetworkFailure extends Failure {
  /// NetworkFailure 생성자
  /// [message]은 실패 메시지입니다.
  /// [exception]은 예외입니다.
  /// [stackTrace]은 스택 트레이스입니다.
  const NetworkFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 서버 오류
class ServerFailure extends Failure {
  /// ServerFailure 생성자
  /// [message]은 실패 메시지입니다.
  /// [exception]은 예외입니다.
  /// [stackTrace]은 스택 트레이스입니다.
  const ServerFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 인증 오류
class AuthenticationFailure extends Failure {
  /// AuthenticationFailure 생성자
  /// [message]은 실패 메시지입니다.
  /// [exception]은 예외입니다.
  /// [stackTrace]은 스택 트레이스입니다.
  const AuthenticationFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}
