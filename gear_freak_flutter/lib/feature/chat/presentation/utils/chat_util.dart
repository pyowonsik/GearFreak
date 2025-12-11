import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';

/// 채팅 메시지 관련 유틸리티 함수
class ChatUtil {

  /// 채팅 메시지 시간 포맷팅
  ///
  /// [dateTime]는 포맷팅할 날짜/시간입니다.
  /// 오늘인 경우: "오후 2:30" 형식
  /// 다른 날인 경우: "12/25 오후 2:30" 형식
  static String formatChatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    if (messageDate == today) {
      // 오늘인 경우: 오후 2:30 형식
      return '$period $displayHour:$minute';
    } else {
      // 다른 날인 경우: 12/25 오후 2:30 형식
      return '${dateTime.month}/${dateTime.day} $period $displayHour:$minute';
    }
  }

  /// ChatMessageResponseDto를 flutter_chat_types Message로 변환
  ///
  /// [messages]는 변환할 메시지 목록입니다.
  /// [participants]는 참여자 목록입니다.
  /// [currentUserId]는 현재 사용자 ID입니다.
  /// [ref]는 Riverpod의 WidgetRef입니다. (현재 사용자 정보 조회용)
  static List<types.Message> convertChatMessages(
    List<pod.ChatMessageResponseDto> messages,
    List<pod.ChatParticipantInfoDto> participants,
    int? currentUserId,
    WidgetRef ref,
  ) {
    if (messages.isEmpty) {
      return [];
    }

    return messages.map((message) {
      final senderId = message.senderId.toString();
      final isCurrentUser = currentUserId?.toString() == senderId;

      types.User author;
      if (isCurrentUser) {
        final authState = ref.read(authNotifierProvider);
        final user = authState is AuthAuthenticated ? authState.user : null;
        author = types.User(
          id: senderId,
          firstName: user?.nickname ?? '나',
          imageUrl: user?.profileImageUrl,
        );
      } else {
        final participant = participants.firstWhere(
          (p) => p.userId.toString() == senderId,
          orElse: () => participants.first,
        );
        author = types.User(
          id: senderId,
          firstName: participant.nickname ?? '사용자',
          imageUrl: participant.profileImageUrl,
        );
      }

      return types.TextMessage(
        author: author,
        createdAt: message.createdAt.millisecondsSinceEpoch,
        id: message.id.toString(),
        text: message.content,
      );
    }).toList();
  }

  /// 메시지 시간 표시 여부 결정 (카카오톡 방식)
  ///
  /// 같은 시간대의 메시지 그룹에서 가장 마지막(최신) 메시지에만 시간 표시
  /// [index]는 현재 메시지의 인덱스입니다. (reverse: true일 때 index 0이 최신 메시지)
  /// [currentMessage]는 현재 메시지입니다.
  /// [previousMessage]는 이전 메시지입니다. (더 최신 메시지, null 가능)
  /// [currentTime]는 현재 메시지의 포맷된 시간입니다.
  /// [previousTime]는 이전 메시지의 포맷된 시간입니다. (null 가능)
  static bool shouldShowMessageTime({
    required int index,
    required types.Message currentMessage,
    types.Message? previousMessage,
    required String currentTime,
    String? previousTime,
  }) {
    // 첫 번째 메시지(가장 최신)는 항상 시간 표시
    if (index == 0) {
      return true;
    }

    // 이전 메시지가 없으면 시간 표시
    if (previousMessage == null || previousTime == null) {
      return true;
    }

    // 이전 메시지와 시간이 다르면 현재 메시지에 시간 표시
    // (같은 시간대 그룹의 마지막 메시지)
    if (currentTime != previousTime ||
        previousMessage.author.id != currentMessage.author.id) {
      return true;
    }

    // 같은 시간대이고 같은 작성자면 시간 표시 안 함
    return false;
  }
}
