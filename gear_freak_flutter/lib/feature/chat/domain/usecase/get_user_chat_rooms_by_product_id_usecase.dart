import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';

/// 사용자가 참여한 채팅방 목록 조회 UseCase (상품 ID 기준, 페이지네이션)
class GetUserChatRoomsByProductIdUseCase
    implements
        UseCase<pod.PaginatedChatRoomsResponseDto, GetUserChatRoomsByProductIdParams,
            ChatRepository> {
  /// GetUserChatRoomsByProductIdUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const GetUserChatRoomsByProductIdUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, pod.PaginatedChatRoomsResponseDto>> call(
    GetUserChatRoomsByProductIdParams param,
  ) async {
    try {
      final result = await repository.getUserChatRoomsByProductId(
        productId: param.productId,
        pagination: param.pagination,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetUserChatRoomsByProductIdFailure(
          '참여한 채팅방 목록을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 사용자가 참여한 채팅방 목록 조회 파라미터
class GetUserChatRoomsByProductIdParams {
  /// GetUserChatRoomsByProductIdParams 생성자
  ///
  /// [productId]는 상품 ID입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  const GetUserChatRoomsByProductIdParams({
    required this.productId,
    required this.pagination,
  });

  /// 상품 ID
  final int productId;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;
}
