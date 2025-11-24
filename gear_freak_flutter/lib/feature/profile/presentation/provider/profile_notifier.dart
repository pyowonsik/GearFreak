import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/profile/domain/domain.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/profile_state.dart';

/// 프로필 Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  /// ProfileNotifier 생성자
  ///
  /// [getUserProfileUseCase]는 사용자 프로필 조회 UseCase 인스턴스입니다.
  /// [getUserByIdUseCase]는 사용자 ID로 사용자 정보 조회 UseCase 인스턴스입니다.
  ProfileNotifier(
    this.getUserProfileUseCase,
    this.getUserByIdUseCase,
  ) : super(const ProfileState());

  /// 사용자 프로필 조회 UseCase 인스턴스
  final GetUserProfileUseCase getUserProfileUseCase;

  /// 사용자 ID로 사용자 정보 조회 UseCase 인스턴스
  final GetUserByIdUseCase getUserByIdUseCase;

  /// 프로필 로드
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

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
