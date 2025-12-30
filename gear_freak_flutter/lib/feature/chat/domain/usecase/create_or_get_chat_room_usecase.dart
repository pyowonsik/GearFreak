import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 채팅방 생성 또는 조회 UseCase
class CreateOrGetChatRoomUseCase
    implements
        UseCase<pod.CreateChatRoomResponseDto, CreateOrGetChatRoomParams,
            ChatRepository> {
  /// CreateOrGetChatRoomUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const CreateOrGetChatRoomUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, pod.CreateChatRoomResponseDto>> call(
    CreateOrGetChatRoomParams param,
  ) async {
    try {
      final result = await repository.createOrGetChatRoom(
        productId: param.productId,
        targetUserId: param.targetUserId,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(
        CreateOrGetChatRoomFailure(
          '채팅방 생성 또는 조회에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 채팅방 생성 또는 조회 파라미터
class CreateOrGetChatRoomParams {
  /// CreateOrGetChatRoomParams 생성자
  ///
  /// [productId]는 상품 ID입니다.
  /// [targetUserId]는 상대방 사용자 ID입니다 (1:1 채팅의 경우).
  const CreateOrGetChatRoomParams({
    required this.productId,
    this.targetUserId,
  });

  /// 상품 ID
  final int productId;

  /// 상대방 사용자 ID (1:1 채팅의 경우)
  final int? targetUserId;
}
