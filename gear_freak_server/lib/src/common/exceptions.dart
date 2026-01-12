import 'package:serverpod/serverpod.dart';

/// 리소스를 찾을 수 없을 때
///
/// 데이터베이스에서 특정 리소스를 찾을 수 없을 때 발생합니다.
class NotFoundException extends SerializableException {
  /// 리소스 이름
  final String resource;

  /// 리소스 ID (선택)
  final int? id;

  NotFoundException(this.resource, [this.id]);

  @override
  String toString() =>
      '$resource${id != null ? ' (id: $id)' : ''}을(를) 찾을 수 없습니다.';
}

/// 권한이 없을 때
///
/// 사용자가 특정 작업을 수행할 권한이 없을 때 발생합니다.
class UnauthorizedException extends SerializableException {
  /// 에러 메시지
  final String message;

  UnauthorizedException([this.message = '권한이 없습니다.']);

  @override
  String toString() => message;
}

/// 중복 데이터
///
/// 이미 존재하는 데이터를 생성하려고 할 때 발생합니다.
class DuplicateException extends SerializableException {
  /// 에러 메시지
  final String message;

  DuplicateException([this.message = '이미 존재하는 데이터입니다.']);

  @override
  String toString() => message;
}

/// 유효성 검증 실패
///
/// 입력 데이터가 유효성 검증을 통과하지 못했을 때 발생합니다.
class ValidationException extends SerializableException {
  /// 필드 이름
  final String field;

  /// 에러 메시지
  final String message;

  ValidationException(this.field, this.message);

  @override
  String toString() => '$field: $message';
}

/// 인증 실패
///
/// 사용자 인증이 실패했을 때 발생합니다.
class AuthenticationException extends SerializableException {
  /// 에러 메시지
  final String message;

  AuthenticationException([this.message = '인증이 필요합니다.']);

  @override
  String toString() => message;
}
