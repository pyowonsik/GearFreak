import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/auth/domain/usecase/get_me_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/profile_state.dart';

/// 프로필 Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  /// ProfileNotifier 생성자
  ///
  /// [getMeUseCase]는 현재 사용자 정보 조회 UseCase 인스턴스입니다.
  /// [getUserByIdUseCase]는 사용자 ID로 사용자 정보 조회 UseCase 인스턴스입니다.
  ProfileNotifier(
    this.getMeUseCase,
    this.getUserByIdUseCase,
  ) : super(const ProfileState());

  /// 현재 사용자 정보 조회 UseCase 인스턴스
  final GetMeUseCase getMeUseCase;

  /// 사용자 ID로 사용자 정보 조회 UseCase 인스턴스
  final GetUserByIdUseCase getUserByIdUseCase;

  /// 프로필 로드
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getMeUseCase(null);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (user) {
        if (user != null) {
          state = state.copyWith(
            user: user,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: '사용자 정보를 불러올 수 없습니다. 로그인 상태를 확인해주세요.',
          );
        }
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
