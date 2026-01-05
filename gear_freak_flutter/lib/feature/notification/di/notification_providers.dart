import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/notification/data/datasource/notification_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/notification/data/repository/notification_repository_impl.dart';
import 'package:gear_freak_flutter/feature/notification/domain/repository/notification_repository.dart';
import 'package:gear_freak_flutter/feature/notification/domain/usecase/usecases.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/provider/notification_list_notifier.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/provider/notification_list_state.dart';
import 'package:gear_freak_flutter/feature/review/di/review_providers.dart';

/// 알림 원격 데이터 소스 Provider
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>(
  (ref) => const NotificationRemoteDataSource(),
);

/// 알림 리포지토리 Provider
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    ref.read(notificationRemoteDataSourceProvider),
  ),
);

/// 알림 목록 조회 UseCase Provider
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>(
  (ref) {
    final repository = ref.watch(notificationRepositoryProvider);
    return GetNotificationsUseCase(repository);
  },
);

/// 알림 읽음 처리 UseCase Provider
final markAsReadUseCaseProvider = Provider<MarkAsReadUseCase>(
  (ref) {
    final repository = ref.watch(notificationRepositoryProvider);
    return MarkAsReadUseCase(repository);
  },
);

/// 알림 삭제 UseCase Provider
final deleteNotificationUseCaseProvider = Provider<DeleteNotificationUseCase>(
  (ref) {
    final repository = ref.watch(notificationRepositoryProvider);
    return DeleteNotificationUseCase(repository);
  },
);

/// 읽지 않은 알림 개수 조회 UseCase Provider
final getUnreadCountUseCaseProvider = Provider<GetUnreadCountUseCase>(
  (ref) {
    final repository = ref.watch(notificationRepositoryProvider);
    return GetUnreadCountUseCase(repository);
  },
);

/// 전체 읽지 않은 알림 개수 Provider
/// 홈 화면에서 사용하기 위한 FutureProvider
final totalUnreadNotificationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final useCase = ref.watch(getUnreadCountUseCaseProvider);
  final result = await useCase(null);
  return result.fold(
    (failure) {
      // 실패 시 0 반환
      debugPrint('❌ 읽지 않은 알림 개수 조회 실패: ${failure.message}');
      return 0;
    },
    (count) => count,
  );
});

/// 알림 목록 Notifier Provider
final notificationListNotifierProvider = StateNotifierProvider.autoDispose<
    NotificationListNotifier, NotificationListState>(
  (ref) {
    final getNotificationsUseCase = ref.watch(getNotificationsUseCaseProvider);
    final markAsReadUseCase = ref.watch(markAsReadUseCaseProvider);
    final deleteNotificationUseCase =
        ref.watch(deleteNotificationUseCaseProvider);
    final checkReviewExistsUseCase =
        ref.watch(checkReviewExistsUseCaseProvider);
    final getUnreadCountUseCase = ref.watch(getUnreadCountUseCaseProvider);
    return NotificationListNotifier(
      getNotificationsUseCase,
      markAsReadUseCase,
      deleteNotificationUseCase,
      checkReviewExistsUseCase,
      getUnreadCountUseCase,
    );
  },
);
