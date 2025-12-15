import 'package:gear_freak_server/src/common/authenticated_mixin.dart';
import 'package:gear_freak_server/src/common/s3/service/s3_service.dart';
import 'package:gear_freak_server/src/feature/chat/service/chat_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 채팅 엔드포인트
class ChatEndpoint extends Endpoint with AuthenticatedMixin {
  final ChatService chatService = ChatService();

  // ==================== Public Methods (Endpoint에서 직접 호출) ====================

  /// 채팅방 생성 또는 조회
  /// 상품 ID와 상대방 사용자 ID로 기존 채팅방을 찾거나 새로 생성합니다.
  Future<CreateChatRoomResponseDto> createOrGetChatRoom(
    Session session,
    CreateChatRoomRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await chatService.createOrGetChatRoom(
      session,
      user.id!,
      request,
    );
  }

  /// 채팅방 정보 조회
  Future<ChatRoom?> getChatRoomById(
    Session session,
    int chatRoomId,
  ) async {
    return await chatService.getChatRoomById(session, chatRoomId);
  }

  /// 상품 ID로 채팅방 목록 조회
  Future<List<ChatRoom>?> getChatRoomsByProductId(
    Session session,
    int productId,
  ) async {
    return await chatService.getChatRoomsByProductId(session, productId);
  }

  /// 사용자가 참여한 채팅방 목록 조회 (상품 ID 기준, 페이지네이션)
  Future<PaginatedChatRoomsResponseDto> getUserChatRoomsByProductId(
    Session session,
    int productId,
    PaginationDto pagination,
  ) async {
    final user = await UserService.getMe(session);
    return await chatService.getUserChatRoomsByProductId(
      session,
      user.id!,
      productId,
      pagination,
    );
  }

  /// 사용자가 참여한 모든 채팅방 목록 조회 (페이지네이션)
  Future<PaginatedChatRoomsResponseDto> getMyChatRooms(
    Session session,
    PaginationDto pagination,
  ) async {
    final user = await UserService.getMe(session);
    return await chatService.getMyChatRooms(
      session,
      user.id!,
      pagination,
    );
  }

  /// 채팅방 참여
  Future<JoinChatRoomResponseDto> joinChatRoom(
    Session session,
    JoinChatRoomRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await chatService.joinChatRoom(
      session,
      user.id!,
      request,
    );
  }

  /// 채팅방 나가기
  Future<LeaveChatRoomResponseDto> leaveChatRoom(
    Session session,
    LeaveChatRoomRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await chatService.leaveChatRoom(
      session,
      user.id!,
      request,
    );
  }

  /// 채팅방 참여자 목록 조회
  Future<List<ChatParticipantInfoDto>> getChatParticipants(
    Session session,
    int chatRoomId,
  ) async {
    return await chatService.getChatParticipants(session, chatRoomId);
  }

  /// 메시지 전송
  Future<ChatMessageResponseDto> sendMessage(
    Session session,
    SendMessageRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await chatService.sendMessage(
      session,
      user.id!,
      request,
    );
  }

  /// 페이지네이션된 메시지 조회
  Future<PaginatedChatMessagesResponseDto> getChatMessagesPaginated(
    Session session,
    GetChatMessagesRequestDto request,
  ) async {
    return await chatService.getChatMessagesPaginated(session, request);
  }

  /// 채팅방의 마지막 메시지 조회
  Future<ChatMessage?> getLastMessageByChatRoomId(
    Session session,
    int chatRoomId,
  ) async {
    return await chatService.getLastMessageByChatRoomId(session, chatRoomId);
  }

  /// 채팅방 이미지 업로드를 위한 Presigned URL 생성
  /// Private 버킷의 chatRoom/{chatRoomId}/ 경로에 바로 업로드
  Future<GeneratePresignedUploadUrlResponseDto> generateChatRoomImageUploadUrl(
    Session session,
    int chatRoomId,
    String fileName,
    String contentType,
    int fileSize,
  ) async {
    final user = await UserService.getMe(session);

    // 채팅방 존재 및 참여 여부 확인
    final participation = await ChatParticipant.db.findFirstRow(
      session,
      where: (participant) =>
          participant.userId.equals(user.id!) &
          participant.chatRoomId.equals(chatRoomId) &
          participant.isActive.equals(true),
    );

    if (participation == null) {
      throw Exception('채팅방에 참여하지 않은 사용자입니다.');
    }

    // Presigned URL 생성
    return await S3Service.generateChatRoomImageUploadUrl(
      session,
      chatRoomId,
      user.id!,
      fileName,
      contentType,
    );
  }

  /// 채팅방 읽음 처리
  /// 채팅방의 모든 메시지를 읽음 처리합니다.
  Future<void> markChatRoomAsRead(
    Session session,
    int chatRoomId,
  ) async {
    final user = await UserService.getMe(session);
    await chatService.markChatRoomAsRead(
      session,
      user.id!,
      chatRoomId,
    );
  }
}
