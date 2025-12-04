import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';

/// 사용자가 참여한 모든 채팅방 목록 조회 UseCase (페이지네이션)
class GetMyChatRoomsUseCase
    implements
        UseCase<pod.PaginatedChatRoomsResponseDto, GetMyChatRoomsParams,
            ChatRepository> {
  /// GetMyChatRoomsUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const GetMyChatRoomsUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Future<Either<Failure, pod.PaginatedChatRoomsResponseDto>> call(
    GetMyChatRoomsParams param,
  ) async {
    try {
      final result = await repository.getMyChatRooms(
        pagination: param.pagination,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetMyChatRoomsFailure(
          '내 채팅방 목록을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 사용자가 참여한 모든 채팅방 목록 조회 파라미터
class GetMyChatRoomsParams {
  /// GetMyChatRoomsParams 생성자
  ///
  /// [pagination]는 페이지네이션 정보입니다.
  const GetMyChatRoomsParams({
    required this.pagination,
  });

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;
}
