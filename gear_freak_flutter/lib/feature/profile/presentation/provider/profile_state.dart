import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 프로필 상태
class ProfileState {
  /// ProfileState 생성자
  ///
  /// [user]는 사용자 정보입니다.
  /// [isLoading]는 로딩 상태입니다.
  /// [error]는 에러 메시지입니다.
  const ProfileState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  /// 사용자 정보
  final pod.User? user;

  /// 로딩 상태
  final bool isLoading;

  /// 에러 메시지
  final String? error;

  /// ProfileState 복사
  ProfileState copyWith({
    pod.User? user,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
