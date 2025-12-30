import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';

/// 프로필 실패 추상 클래스
abstract class ProfileFailure extends Failure {
  /// ProfileFailure 생성자
  const ProfileFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'ProfileFailure: $message';
}

/// 프로필 조회 실패
class GetUserProfileFailure extends ProfileFailure {
  /// GetUserProfileFailure 생성자
  const GetUserProfileFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'GetUserProfileFailure: $message';
}

/// 사용자 ID로 사용자 조회 실패
class GetUserByIdFailure extends ProfileFailure {
  /// GetUserByIdFailure 생성자
  const GetUserByIdFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'GetUserByIdFailure: $message';
}

/// 사용자 프로필 수정 실패
class UpdateUserProfileFailure extends ProfileFailure {
  /// UpdateUserProfileFailure 생성자
  const UpdateUserProfileFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'UpdateUserProfileFailure: $message';
}
