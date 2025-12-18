import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_stats_by_user_id_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/other_user_profile_state.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/get_all_reviews_by_user_id_usecase.dart';

/// 다른 사용자 프로필 Notifier
class OtherUserProfileNotifier extends StateNotifier<OtherUserProfileState> {
  /// OtherUserProfileNotifier 생성자
  OtherUserProfileNotifier(
    this.getUserByIdUseCase,
    this.getProductStatsByUserIdUseCase,
    this.getAllReviewsByUserIdUseCase,
  ) : super(const OtherUserProfileInitial());

  /// 사용자 ID로 사용자 정보 조회 UseCase
  final GetUserByIdUseCase getUserByIdUseCase;

  /// 다른 사용자의 상품 통계 조회 UseCase
  final GetProductStatsByUserIdUseCase getProductStatsByUserIdUseCase;

  /// 다른 사용자의 모든 후기 조회 UseCase
  final GetAllReviewsByUserIdUseCase getAllReviewsByUserIdUseCase;

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
    if (state is! OtherUserProfileLoaded) {
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

        // 최신 state를 읽어서 업데이트 (copyWith가 기존 값들을 자동으로 유지)
        final latestState = state;
        if (latestState is OtherUserProfileLoaded) {
          state = latestState.copyWith(stats: stats);
        }
      },
    );
  }

  /// 후기 목록 로드 (최대 3개)
  Future<void> loadReviews(int userId) async {
    if (state is! OtherUserProfileLoaded) {
      debugPrint('⚠️ [OtherUserProfileNotifier] 프로필이 로드되지 않아 후기 목록을'
          ' 불러올 수 없습니다.');
      return;
    }

    debugPrint('🔄 [OtherUserProfileNotifier] 후기 목록 로드 시작: userId=$userId');

    final result = await getAllReviewsByUserIdUseCase(
      GetAllReviewsByUserIdParams(
        userId: userId,
        page: 1,
        limit: 3, // 최대 3개만 조회
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [OtherUserProfileNotifier] 후기 목록 로드 실패:'
            ' ${failure.message}');
        // 후기 목록 로드 실패해도 프로필은 유지
      },
      (response) {
        debugPrint('✅ [OtherUserProfileNotifier] 후기 목록 로드 성공:'
            ' reviews=${response.reviews.length}개,'
            ' averageRating=${response.averageRating}');
        // 최대 3개만 저장
        final reviews = response.reviews.take(3).toList();
        debugPrint('📝 [OtherUserProfileNotifier] 저장할 후기: ${reviews.length}개');

        // 최신 state를 읽어서 업데이트 (copyWith가 기존 값들을 자동으로 유지)
        final latestState = state;
        if (latestState is OtherUserProfileLoaded) {
          state = latestState.copyWith(
            reviews: reviews,
            averageRating: response.averageRating,
          );
        }
        debugPrint('✅ [OtherUserProfileNotifier] State 업데이트 완료:'
            ' reviews=${reviews.length}개, averageRating=${response.averageRating}');
      },
    );
  }
}
