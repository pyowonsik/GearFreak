import 'dart:async';

import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/stream_usecase.dart';

/// 채팅 메시지 스트림 구독 UseCase
/// 실시간 메시지를 받기 위한 스트림을 반환합니다.
class SubscribeChatMessageStreamUseCase
    implements
        StreamUseCase<pod.ChatMessageResponseDto,
            SubscribeChatMessageStreamParams, ChatRepository> {
  /// SubscribeChatMessageStreamUseCase 생성자
  ///
  /// [repository]는 채팅 Repository 인스턴스입니다.
  const SubscribeChatMessageStreamUseCase(this.repository);

  /// 채팅 Repository 인스턴스
  final ChatRepository repository;

  @override
  ChatRepository get repo => repository;

  @override
  Stream<pod.ChatMessageResponseDto> call(
    SubscribeChatMessageStreamParams param,
  ) {
    return repository.subscribeChatMessageStream(param.chatRoomId);
  }
}

/// 채팅 메시지 스트림 구독 파라미터
class SubscribeChatMessageStreamParams {
  /// SubscribeChatMessageStreamParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  const SubscribeChatMessageStreamParams({
    required this.chatRoomId,
  });

  /// 채팅방 ID
  final int chatRoomId;
}
