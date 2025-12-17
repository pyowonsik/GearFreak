import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/other_user_profile_state.dart';

/// 다른 사용자 프로필 Notifier
class OtherUserProfileNotifier extends StateNotifier<OtherUserProfileState> {
  /// OtherUserProfileNotifier 생성자
  OtherUserProfileNotifier(this.getUserByIdUseCase)
      : super(const OtherUserProfileInitial());

  /// 사용자 ID로 사용자 정보 조회 UseCase
  final GetUserByIdUseCase getUserByIdUseCase;

  /// 사용자 프로필 로드
  Future<void> loadUserProfile(int userId) async {
    state = const OtherUserProfileLoading();

    final result = await getUserByIdUseCase(userId);

    result.fold(
      (failure) {
        debugPrint('❌ [OtherUserProfileNotifier] 사용자 프로필 로드 실패:'
            ' ${failure.message}');
        state = OtherUserProfileError(failure.message);
      },
      (user) {
        debugPrint('✅ [OtherUserProfileNotifier] 사용자 프로필 로드 성공:'
            ' userId=${user.id}, nickname=${user.nickname}');
        state = OtherUserProfileLoaded(user: user);
      },
    );
  }
}
