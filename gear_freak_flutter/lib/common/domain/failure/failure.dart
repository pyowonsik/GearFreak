/// 실패를 나타내는 추상 클래스
abstract class Failure {
  final String message;
  final Exception? exception;
  final StackTrace? stackTrace;

  const Failure(
    this.message, {
    this.exception,
    this.stackTrace,
  });

  /// 예상치 못한 오류
  factory Failure.unexpected(String message, {Exception? exception}) {
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

  @override
  String toString() => message;
}

/// 예상치 못한 오류
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 네트워크 오류
class NetworkFailure extends Failure {
  const NetworkFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 서버 오류
class ServerFailure extends Failure {
  const ServerFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}

/// 인증 오류
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}
