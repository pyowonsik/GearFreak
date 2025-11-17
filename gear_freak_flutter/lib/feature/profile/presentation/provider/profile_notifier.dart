import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/domain.dart';

/// 프로필 상태
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

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

/// 프로필 Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;

  ProfileNotifier(
    this.getUserProfileUseCase,
    this.getUserByIdUseCase,
  ) : super(const ProfileState());

  /// 프로필 로드
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getUserProfileUseCase(null);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (profile) {
        state = state.copyWith(
          profile: profile,
          isLoading: false,
        );
      },
    );
  }

  /// 사용자 ID로 사용자 정보 조회
  Future<pod.User?> getUserById(int id) async {
    final result = await getUserByIdUseCase(id);
    return result.fold(
      (failure) {
        // 에러 발생 시 null 반환
        return null;
      },
      (user) => user,
    );
  }
}
