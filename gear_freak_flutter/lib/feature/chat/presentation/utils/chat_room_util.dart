import 'package:chat_group_avatar/group_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';

/// 채팅방 관련 유틸리티 함수
class ChatRoomUtil {
  /// 상대방 참여자 정보 가져오기
  ///
  /// [ref]는 Riverpod의 WidgetRef입니다.
  /// [participants]는 참여자 목록입니다.
  /// 반환: 상대방 참여자 정보 (없으면 null)
  static pod.ChatParticipantInfoDto? getOtherParticipant(
    WidgetRef ref, {
    List<pod.ChatParticipantInfoDto>? participants,
  }) {
    // 현재 사용자 ID 가져오기
    final authState = ref.read(authNotifierProvider);
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    // 참여자 정보가 있고 현재 사용자 ID가 있으면 상대방 찾기
    if (participants != null &&
        participants.isNotEmpty &&
        currentUserId != null) {
      try {
        return participants.firstWhere(
          (p) => p.userId != currentUserId,
        );
      } catch (e) {
        // 상대방을 찾지 못한 경우 첫 번째 참여자 반환
        return participants.first;
      }
    }

    // 참여자 정보가 없거나 현재 사용자 ID가 없으면 null
    return null;
  }

  /// 상대방 닉네임 가져오기
  ///
  /// [ref]는 Riverpod의 WidgetRef입니다.
  /// [participants]는 참여자 목록입니다.
  /// [defaultName]는 기본값입니다.
  static String getOtherParticipantName(
    WidgetRef ref, {
    List<pod.ChatParticipantInfoDto>? participants,
    String defaultName = '채팅방',
  }) {
    final otherParticipant = getOtherParticipant(
      ref,
      participants: participants,
    );

    if (otherParticipant != null) {
      return otherParticipant.nickname ?? '사용자';
    }

    // 참여자 정보가 없거나 현재 사용자 ID가 없으면 기본값
    return defaultName;
  }

  /// 채팅방 아바타 위젯 빌드
  ///
  /// [participants]는 참여자 목록입니다.
  /// [size]는 아바타 크기입니다. (기본값: 56)
  /// [useCircleAvatar]는 CircleAvatar를 사용할지 여부입니다. (기본값: false)
  /// [defaultIcon]는 기본 아이콘입니다. (기본값: Icons.person)
  /// [defaultSize]는 기본 아이콘 크기입니다. (기본값: 28)
  static Widget buildChatRoomAvatar({
    List<pod.ChatParticipantInfoDto>? participants,
    double size = 56,
    bool useCircleAvatar = false,
    IconData defaultIcon = Icons.person,
    double defaultSize = 28,
  }) {
    // 참여자 정보가 있으면 그룹 아바타 사용
    if (participants != null && participants.isNotEmpty) {
      // 현재 사용자 제외하고 프로필 이미지 URL 수집
      final imageUrls = participants
          .map((p) => p.profileImageUrl)
          .where((url) => url != null && url.isNotEmpty)
          .take(4) // 최대 4명까지
          .toList();

      if (imageUrls.isNotEmpty) {
        return GroupAvatar(
          imageUrls: imageUrls,
          size: size,
          borderColor: Colors.white,
        );
      }
    }

    // 참여자 정보가 없거나 이미지가 없으면 기본 아이콘 표시
    if (useCircleAvatar) {
      return CircleAvatar(
        radius: defaultSize,
        backgroundColor: const Color(0xFFF3F4F6),
        child: Icon(
          defaultIcon,
          color: Colors.grey.shade500,
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          defaultIcon,
          size: defaultSize,
          color: const Color(0xFF9CA3AF),
        ),
      );
    }
  }

  /// 채팅방 시간 포맷팅
  ///
  /// [dateTime]는 포맷팅할 날짜/시간입니다.
  /// 24시간 이내(오늘): 시간만 표기 (예: "오후 2:30")
  /// 하루가 지나면: formatRelativeTime()과 같은 방식으로 표기
  static String formatChatRoomTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // 24시간 이내(오늘): 시간만 표기
    if (difference.inHours < 24 && difference.inDays < 1) {
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour >= 12 ? '오후' : '오전';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
    }

    // 하루가 지나면: formatRelativeTime()과 같은 방식
    // 일 단위 (1일 이상, 7일 미만)
    if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    }
    // 주 단위 (1주 이상, 4주 이하, 즉 28일 이하)
    else if (difference.inDays <= 28) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks주일 전';
    }
    // 개월 단위 (29일 이상, 365일 미만, 즉 약 1개월 이상)
    else if (difference.inDays < 365) {
      // 대략적인 개월 수 계산 (30일 기준)
      final months = (difference.inDays / 30).floor();
      // months가 0이 되는 경우 방지 (29일 이상이므로 최소 1개월)
      final displayMonths = months.clamp(1, 12);
      return '$displayMonths개월 전';
    }
    // 년 단위 (1년 이상)
    else {
      final years = (difference.inDays / 365).floor();
      return '$years년 전';
    }
  }

  /// 현재 사용자의 알림 설정 상태 가져오기
  ///
  /// [ref]는 Riverpod의 WidgetRef입니다.
  /// [participants]는 참여자 목록입니다.
  /// 반환: 알림 활성화 여부 (기본값: true)
  static bool getCurrentUserNotificationEnabled(
    WidgetRef ref, {
    List<pod.ChatParticipantInfoDto>? participants,
  }) {
    // 현재 사용자 ID 가져오기
    final authState = ref.read(authNotifierProvider);
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    // 참여자 정보가 있고 현재 사용자 ID가 있으면 현재 사용자의 알림 설정 확인
    if (participants != null &&
        participants.isNotEmpty &&
        currentUserId != null) {
      final currentUserParticipant = participants.firstWhere(
        (p) => p.userId == currentUserId,
        orElse: () => participants.first,
      );

      return currentUserParticipant.isNotificationEnabled;
    }

    // 기본값: 알림 활성화
    return true;
  }

  /// 더미 채팅방 생성 (채팅방이 없을 때 UI 표시용)
  ///
  /// [productId]는 상품 ID입니다.
  static pod.ChatRoom createDummyChatRoom(int productId) {
    return pod.ChatRoom(
      productId: productId,
      chatRoomType: pod.ChatRoomType.direct,
      participantCount: 0,
      lastActivityAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 채팅방 목록에서 표시할 메시지 텍스트 가져오기
  ///
  /// [message]는 메시지 정보입니다.
  /// 메시지 타입에 따라 적절한 텍스트를 반환합니다.
  static String getLastMessageText(pod.ChatMessageResponseDto? message) {
    if (message == null) {
      return '채팅내용이 없습니다.';
    }

    // 메시지 타입에 따라 다른 텍스트 표시
    switch (message.messageType) {
      case pod.MessageType.image:
        return '사진을 보냈습니다.';
      case pod.MessageType.file:
        return '파일을 보냈습니다.';
      case pod.MessageType.text:
      case pod.MessageType.system:
        return message.content;
    }
  }
}
