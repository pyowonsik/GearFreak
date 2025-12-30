import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/notification/domain/failures/notification_failure.dart';
import 'package:gear_freak_flutter/feature/notification/domain/repository/notification_repository.dart';
import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 읽지 않은 알림 개수 조회 UseCase
class GetUnreadCountUseCase
    implements UseCase<int, void, NotificationRepository> {
  /// GetUnreadCountUseCase 생성자
  const GetUnreadCountUseCase(this.repository);

  /// 알림 리포지토리
  final NotificationRepository repository;

  @override
  NotificationRepository get repo => repository;

  @override
  Future<Either<Failure, int>> call(void param) async {
    try {
      final result = await repository.getUnreadCount();
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        GetUnreadCountFailure(
          '읽지 않은 알림 개수 조회에 실패했습니다: $e',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
