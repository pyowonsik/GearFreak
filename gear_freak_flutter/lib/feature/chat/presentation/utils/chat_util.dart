import 'package:chat_group_avatar/group_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';

/// 채팅 관련 유틸리티 함수
class ChatUtil {
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
    // 현재 사용자 ID 가져오기
    final authState = ref.read(authNotifierProvider);
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    // 참여자 정보가 있고 현재 사용자 ID가 있으면 상대방 찾기
    if (participants != null &&
        participants.isNotEmpty &&
        currentUserId != null) {
      final otherParticipant = participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => participants.first,
      );
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
  static String formatChatRoomTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
