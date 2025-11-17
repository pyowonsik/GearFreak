import '../../../../common/domain/failure/failure.dart';

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
  const GetUserProfileFailure(super.message,
      {super.exception, super.stackTrace});

  @override
  String toString() => 'GetUserProfileFailure: $message';
}
