import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';

/// 채팅방 알림 설정 변경 UseCase
class UpdateChatRoomNotificationUseCase
    implements UseCase<void, UpdateChatRoomNotificationParams, ChatRepository> {
  /// UpdateChatRoomNotificationUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const UpdateChatRoomNotificationUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, void>> call(
    UpdateChatRoomNotificationParams param,
  ) async {
    try {
      await repository.updateChatRoomNotification(
        chatRoomId: param.chatRoomId,
        isNotificationEnabled: param.isNotificationEnabled,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(
        UpdateChatRoomNotificationFailure(
          '채팅방 알림 설정 변경에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 채팅방 알림 설정 변경 파라미터
class UpdateChatRoomNotificationParams {
  /// UpdateChatRoomNotificationParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [isNotificationEnabled]는 알림 활성화 여부입니다.
  const UpdateChatRoomNotificationParams({
    required this.chatRoomId,
    required this.isNotificationEnabled,
  });

  /// 채팅방 ID
  final int chatRoomId;

  /// 알림 활성화 여부
  final bool isNotificationEnabled;
}

/// 채팅방 알림 설정 변경 실패
class UpdateChatRoomNotificationFailure extends Failure {
  /// UpdateChatRoomNotificationFailure 생성자
  const UpdateChatRoomNotificationFailure(
    super.message, {
    super.exception,
  });
}
