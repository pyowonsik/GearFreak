import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/notification/domain/failures/notification_failure.dart';
import 'package:gear_freak_flutter/feature/notification/domain/repository/notification_repository.dart';
import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 알림 읽음 처리 UseCase 파라미터
class MarkAsReadParams {
  /// MarkAsReadParams 생성자
  const MarkAsReadParams({required this.notificationId});

  /// 알림 ID
  final int notificationId;
}

/// 알림 읽음 처리 UseCase
class MarkAsReadUseCase
    implements UseCase<bool, MarkAsReadParams, NotificationRepository> {
  /// MarkAsReadUseCase 생성자
  const MarkAsReadUseCase(this.repository);

  /// 알림 리포지토리
  final NotificationRepository repository;

  @override
  NotificationRepository get repo => repository;

  @override
  Future<Either<Failure, bool>> call(MarkAsReadParams param) async {
    try {
      final result = await repository.markAsRead(param.notificationId);
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        MarkAsReadFailure(
          '알림 읽음 처리에 실패했습니다: $e',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
