import 'dart:async';
import 'package:gear_freak_server/src/common/authenticated_mixin.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Redis 기반 실시간 채팅 스트림 관리 엔드포인트
class ChatStreamEndpoint extends Endpoint with AuthenticatedMixin {
  /// 채팅방 메시지 스트림 구독 (Redis 기반)
  /// 특정 채팅방의 실시간 메시지를 받기 위한 스트림
  Stream<ChatMessageResponseDto> chatMessageStream(
    Session session,
    int chatRoomId,
  ) async* {
    // 인증 확인
    final isUserSignedIn = await session.isUserSignedIn;
    if (!isUserSignedIn) {
      throw Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
    }

    final userInfo = await session.authenticated;
    if (userInfo == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    // 채팅방 참여 여부 확인
    final participation = await ChatParticipant.db.findFirstRow(
      session,
      where: (participant) =>
          participant.userId.equals(userInfo.userId) &
          participant.chatRoomId.equals(chatRoomId) &
          participant.isActive.equals(true),
    );

    if (participation == null) {
      throw Exception('채팅방에 참여하지 않은 사용자입니다.');
    }

    // 🚀 Server Events를 통한 Redis 기반 스트림 생성
    final messageStream = session.messages.createStream<ChatMessageResponseDto>(
      'chat_room_$chatRoomId',
    );

    // 실시간 메시지 스트림 반환
    await for (final message in messageStream) {
      yield message;
    }
  }
}
