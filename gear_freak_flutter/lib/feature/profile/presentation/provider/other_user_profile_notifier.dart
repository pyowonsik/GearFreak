import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_stats_by_user_id_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/other_user_profile_state.dart';

/// 다른 사용자 프로필 Notifier
class OtherUserProfileNotifier extends StateNotifier<OtherUserProfileState> {
  /// OtherUserProfileNotifier 생성자
  OtherUserProfileNotifier(
    this.getUserByIdUseCase,
    this.getProductStatsByUserIdUseCase,
  ) : super(const OtherUserProfileInitial());

  /// 사용자 ID로 사용자 정보 조회 UseCase
  final GetUserByIdUseCase getUserByIdUseCase;

  /// 다른 사용자의 상품 통계 조회 UseCase
  final GetProductStatsByUserIdUseCase getProductStatsByUserIdUseCase;

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

  /// 상품 통계 로드
  Future<void> loadProductStats(int userId) async {
    final currentState = state;
    if (currentState is! OtherUserProfileLoaded) {
      debugPrint('⚠️ [OtherUserProfileNotifier] 프로필이 로드되지 않아 통계를'
          ' 불러올 수 없습니다.');
      return;
    }

    final result = await getProductStatsByUserIdUseCase(
      GetProductStatsByUserIdParams(userId),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [OtherUserProfileNotifier] 상품 통계 로드 실패:'
            ' ${failure.message}');
        // 통계 로드 실패해도 프로필은 유지
      },
      (stats) {
        debugPrint('✅ [OtherUserProfileNotifier] 상품 통계 로드 성공:'
            ' sellingCount=${stats.sellingCount},'
            ' soldCount=${stats.soldCount},'
            ' reviewCount=${stats.reviewCount}');
        state = currentState.copyWith(stats: stats);
      },
    );
  }
}
