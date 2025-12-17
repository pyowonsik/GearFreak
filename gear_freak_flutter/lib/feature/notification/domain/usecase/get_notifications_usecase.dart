import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/failure/failure.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/notification/domain/failures/notification_failure.dart';
import 'package:gear_freak_flutter/feature/notification/domain/repository/notification_repository.dart';

/// 알림 목록 조회 UseCase 파라미터
class GetNotificationsParams {
  /// GetNotificationsParams 생성자
  const GetNotificationsParams({
    this.page = 1,
    this.limit = 10,
  });

  /// 페이지 번호
  final int page;

  /// 페이지당 항목 수
  final int limit;
}

/// 알림 목록 조회 UseCase
class GetNotificationsUseCase
    implements
        UseCase<pod.NotificationListResponseDto, GetNotificationsParams,
            NotificationRepository> {
  /// GetNotificationsUseCase 생성자
  const GetNotificationsUseCase(this.repository);

  /// 알림 리포지토리
  final NotificationRepository repository;

  @override
  NotificationRepository get repo => repository;

  @override
  Future<Either<Failure, pod.NotificationListResponseDto>> call(
    GetNotificationsParams param,
  ) async {
    try {
      final result = await repository.getNotifications(
        page: param.page,
        limit: param.limit,
      );
      return Right(result);
    } on Exception catch (e, stackTrace) {
      return Left(
        GetNotificationsFailure(
          '알림 목록을 불러오는데 실패했습니다: $e',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
