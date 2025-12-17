import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/notification/data/datasource/notification_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/notification/data/repository/notification_repository_impl.dart';
import 'package:gear_freak_flutter/feature/notification/domain/repository/notification_repository.dart';
import 'package:gear_freak_flutter/feature/notification/domain/usecase/usecases.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/provider/notification_list_notifier.dart';
import 'package:gear_freak_flutter/feature/notification/presentation/provider/notification_list_state.dart';

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

/// 알림 목록 Notifier Provider
final notificationListNotifierProvider = StateNotifierProvider.autoDispose<
    NotificationListNotifier, NotificationListState>(
  (ref) {
    final getNotificationsUseCase = ref.watch(getNotificationsUseCaseProvider);
    final markAsReadUseCase = ref.watch(markAsReadUseCaseProvider);
    final deleteNotificationUseCase =
        ref.watch(deleteNotificationUseCaseProvider);
    return NotificationListNotifier(
      getNotificationsUseCase,
      markAsReadUseCase,
      deleteNotificationUseCase,
    );
  },
);
