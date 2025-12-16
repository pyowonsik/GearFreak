import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';
import 'package:gear_freak_flutter/feature/review/domain/failures/review_failure.dart';

/// 상품 ID로 구매자 목록 조회 UseCase
class GetBuyersByProductIdUseCase
    implements UseCase<List<BuyerInfo>, GetBuyersByProductIdParams, void> {
  /// GetBuyersByProductIdUseCase 생성자
  ///
  /// [getUserChatRoomsByProductIdUseCase]는 채팅방 목록 조회 UseCase입니다.
  /// [getChatParticipantsUseCase]는 채팅방 참여자 조회 UseCase입니다.
  /// [getProductDetailUseCase]는 상품 상세 조회 UseCase입니다.
  const GetBuyersByProductIdUseCase(
    this.getUserChatRoomsByProductIdUseCase,
    this.getChatParticipantsUseCase,
    this.getProductDetailUseCase,
  );

  /// 채팅방 목록 조회 UseCase
  final GetUserChatRoomsByProductIdUseCase getUserChatRoomsByProductIdUseCase;

  /// 채팅방 참여자 조회 UseCase
  final GetChatParticipantsUseCase getChatParticipantsUseCase;

  /// 상품 상세 조회 UseCase
  final GetProductDetailUseCase getProductDetailUseCase;

  @override
  void get repo => throw UnimplementedError(
        'GetBuyersByProductIdUseCase는 여러 UseCase를 조합하므로 repo가 없습니다.',
      );

  @override
  Future<Either<Failure, List<BuyerInfo>>> call(
    GetBuyersByProductIdParams param,
  ) async {
    try {
      // 1. 상품 정보 조회 (sellerId 가져오기)
      final productResult = await getProductDetailUseCase(param.productId);
      final product = await productResult.fold(
        (failure) => throw Exception('상품 정보를 불러올 수 없습니다: ${failure.message}'),
        (product) async => product,
      );

      // 2. 해당 상품의 채팅방 목록 조회
      final chatRoomsResult = await getUserChatRoomsByProductIdUseCase(
        GetUserChatRoomsByProductIdParams(
          productId: param.productId,
          pagination: pod.PaginationDto(page: 1, limit: 100), // 충분히 큰 값
        ),
      );

      final chatRooms = await chatRoomsResult.fold(
        (failure) => throw Exception(
          '채팅방 목록을 불러올 수 없습니다: ${failure.message}',
        ),
        (response) async => response.chatRooms,
      );

      if (chatRooms.isEmpty) {
        return const Right([]);
      }

      // 3. 각 채팅방의 참여자 정보 조회 및 구매자 필터링
      final buyers = <BuyerInfo>[];
      final sellerId = product.sellerId;

      for (final chatRoom in chatRooms) {
        if (chatRoom.id == null) continue;

        final participantsResult = await getChatParticipantsUseCase(
          GetChatParticipantsParams(chatRoomId: chatRoom.id!),
        );

        participantsResult.fold(
          (failure) {
            // 참여자 조회 실패 시 해당 채팅방은 건너뜀
          },
          (participants) {
            // 판매자가 아닌 참여자 찾기 (구매자)
            for (final participant in participants) {
              if (participant.userId != sellerId) {
                // 중복 제거 (같은 구매자가 여러 채팅방에 있을 수 있음)
                final existingBuyer = buyers.firstWhere(
                  (buyer) => buyer.userId == participant.userId,
                  orElse: () => BuyerInfo(
                    userId: -1,
                    chatRoomId: -1,
                  ),
                );

                if (existingBuyer.userId == -1) {
                  buyers.add(
                    BuyerInfo(
                      userId: participant.userId,
                      chatRoomId: chatRoom.id!,
                      nickname: participant.nickname,
                      profileImageUrl: participant.profileImageUrl,
                    ),
                  );
                }
              }
            }
          },
        );
      }

      return Right(buyers);
    } on Exception catch (e) {
      return Left(
        GetBuyersByProductIdFailure(
          '구매자 목록을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 상품 ID로 구매자 목록 조회 파라미터
class GetBuyersByProductIdParams {
  /// GetBuyersByProductIdParams 생성자
  ///
  /// [productId]는 상품 ID입니다.
  const GetBuyersByProductIdParams({
    required this.productId,
  });

  /// 상품 ID
  final int productId;
}

/// 구매자 정보
class BuyerInfo {
  /// BuyerInfo 생성자
  ///
  /// [userId]는 구매자 사용자 ID입니다.
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [nickname]는 구매자 닉네임입니다.
  /// [profileImageUrl]는 구매자 프로필 이미지 URL입니다.
  const BuyerInfo({
    required this.userId,
    required this.chatRoomId,
    this.nickname,
    this.profileImageUrl,
  });

  /// 구매자 사용자 ID
  final int userId;

  /// 채팅방 ID
  final int chatRoomId;

  /// 구매자 닉네임
  final String? nickname;

  /// 구매자 프로필 이미지 URL
  final String? profileImageUrl;
}
