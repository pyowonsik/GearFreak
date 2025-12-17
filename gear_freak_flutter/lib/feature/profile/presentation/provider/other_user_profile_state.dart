import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 다른 사용자 프로필 상태
sealed class OtherUserProfileState {
  /// OtherUserProfileState 생성자
  const OtherUserProfileState();
}

/// 초기 상태
class OtherUserProfileInitial extends OtherUserProfileState {
  /// OtherUserProfileInitial 생성자
  const OtherUserProfileInitial();
}

/// 로딩 중
class OtherUserProfileLoading extends OtherUserProfileState {
  /// OtherUserProfileLoading 생성자
  const OtherUserProfileLoading();
}

/// 로딩 완료
class OtherUserProfileLoaded extends OtherUserProfileState {
  /// OtherUserProfileLoaded 생성자
  const OtherUserProfileLoaded({
    required this.user,
  });

  /// 사용자 정보
  final pod.User user;
}

/// 에러 상태
class OtherUserProfileError extends OtherUserProfileState {
  /// OtherUserProfileError 생성자
  const OtherUserProfileError(this.message);

  /// 에러 메시지
  final String message;
}
