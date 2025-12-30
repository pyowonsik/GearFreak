import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/notification/domain/failures/notification_failure.dart';
import 'package:gear_freak_flutter/feature/notification/domain/repository/notification_repository.dart';
import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 알림 삭제 UseCase 파라미터
class DeleteNotificationParams {
  /// DeleteNotificationParams 생성자
  const DeleteNotificationParams({required this.notificationId});

  /// 알림 ID
  final int notificationId;
}

/// 알림 삭제 UseCase
class DeleteNotificationUseCase
    implements UseCase<bool, DeleteNotificationParams, NotificationRepository> {
  /// DeleteNotificationUseCase 생성자
  const DeleteNotificationUseCase(this.repository);

  /// 알림 리포지토리
  final NotificationRepository repository;

  @override
  NotificationRepository get repo => repository;

  @override
  Future<Either<Failure, bool>> call(DeleteNotificationParams param) async {
    try {
      final result = await repository.deleteNotification(param.notificationId);
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        DeleteNotificationFailure(
          '알림 삭제에 실패했습니다: $e',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
