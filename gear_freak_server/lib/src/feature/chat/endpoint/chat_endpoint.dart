import 'package:gear_freak_server/src/common/authenticated_mixin.dart';
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

  /// 사용자가 참여한 채팅방 목록 조회 (상품 ID 기준)
  Future<List<ChatRoom>?> getUserChatRoomsByProductId(
    Session session,
    int productId,
  ) async {
    final user = await UserService.getMe(session);
    return await chatService.getUserChatRoomsByProductId(
      session,
      user.id!,
      productId,
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
}
