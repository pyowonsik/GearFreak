import 'package:gear_freak_flutter/feature/profile/domain/domain.dart';

/// 프로필 상태
class ProfileState {
  /// ProfileState 생성자
  ///
  /// [profile]는 사용자 프로필입니다.
  /// [isLoading]는 로딩 상태입니다.
  /// [error]는 에러 메시지입니다.
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  /// 사용자 프로필
  final UserProfile? profile;

  /// 로딩 상태
  final bool isLoading;

  /// 에러 메시지
  final String? error;

  /// ProfileState 복사
  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

