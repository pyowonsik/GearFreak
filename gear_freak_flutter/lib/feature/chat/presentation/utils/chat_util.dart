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

      // 이미지 메시지인 경우 ImageMessage로 변환
      if (message.messageType == pod.MessageType.image &&
          message.attachmentUrl != null) {
        return types.ImageMessage(
          author: author,
          createdAt: message.createdAt.millisecondsSinceEpoch,
          id: message.id.toString(),
          name: message.attachmentName ?? message.content,
          size: message.attachmentSize?.toDouble() ?? 0,
          uri: message.attachmentUrl!,
        );
      }

      // 파일 메시지인 경우 (동영상 포함)
      // content에 썸네일 URL이 들어있고, attachmentUrl에 실제 파일 URL이 들어있음
      if (message.messageType == pod.MessageType.file &&
          message.attachmentUrl != null) {
        // 동영상 파일인지 확인 (attachmentName의 확장자로 판단)
        final isVideo = ChatUtil.isVideoFile(message.attachmentName);

        // content가 URL 형식이면 썸네일 URL로 간주
        final isThumbnailUrl = message.content.startsWith('http://') ||
            message.content.startsWith('https://');

        if (isVideo && isThumbnailUrl) {
          // 동영상: 썸네일을 ImageMessage로 표시하되, 실제 파일 URL은 name에 저장
          // name 형식: "VIDEO_URL:{실제동영상URL}|{파일이름}"
          final videoUrl = message.attachmentUrl!;
          final fileName = message.attachmentName ?? '동영상';
          return types.ImageMessage(
            author: author,
            createdAt: message.createdAt.millisecondsSinceEpoch,
            id: message.id.toString(),
            name: 'VIDEO_URL:$videoUrl|$fileName', // 실제 동영상 URL과 파일 이름 저장
            size: message.attachmentSize?.toDouble() ?? 0,
            uri: message.content, // 썸네일 URL 사용
          );
        } else if (isVideo && !isThumbnailUrl) {
          // 동영상이지만 썸네일 URL이 없는 경우 (썸네일 생성 실패 등)
          // 일단 텍스트로 표시하되, 나중에 썸네일 재생성 가능
          return types.TextMessage(
            author: author,
            createdAt: message.createdAt.millisecondsSinceEpoch,
            id: message.id.toString(),
            text: message.attachmentName ?? message.content,
          );
        } else {
          // 일반 파일: FileMessage로 변환
          return types.FileMessage(
            author: author,
            createdAt: message.createdAt.millisecondsSinceEpoch,
            id: message.id.toString(),
            name: message.attachmentName ?? message.content,
            size: message.attachmentSize?.toDouble() ?? 0,
            uri: message.attachmentUrl!,
            mimeType: _getMimeTypeFromFileName(message.attachmentName),
          );
        }
      }

      // 기본적으로 TextMessage로 변환
      return types.TextMessage(
        author: author,
        createdAt: message.createdAt.millisecondsSinceEpoch,
        id: message.id.toString(),
        text: message.content,
      );
    }).toList();
  }

  /// 동영상 파일인지 확인
  ///
  /// [fileName]은 확인할 파일 이름입니다. (null 가능)
  static bool isVideoFile(String? fileName) {
    if (fileName == null) return false;

    const videoExtensions = [
      '.mov',
      '.mp4',
      '.avi',
      '.mkv',
      '.webm',
      '.m4v',
      '.3gp',
    ];
    final lowerFileName = fileName.toLowerCase();
    return videoExtensions.any(lowerFileName.endsWith);
  }

  /// 파일 이름에서 Content-Type 결정
  ///
  /// [fileName]은 파일 이름입니다.
  /// 반환값은 MIME 타입 문자열입니다. (예: 'image/jpeg', 'video/mp4')
  static String getContentType(String fileName) {
    final lowerFileName = fileName.toLowerCase();

    // 이미지
    if (lowerFileName.endsWith('.png')) {
      return 'image/png';
    } else if (lowerFileName.endsWith('.webp')) {
      return 'image/webp';
    }
    // 동영상
    else if (lowerFileName.endsWith('.mov')) {
      return 'video/quicktime';
    } else if (lowerFileName.endsWith('.mp4')) {
      return 'video/mp4';
    } else if (lowerFileName.endsWith('.avi')) {
      return 'video/x-msvideo';
    } else if (lowerFileName.endsWith('.mkv')) {
      return 'video/x-matroska';
    } else if (lowerFileName.endsWith('.webm')) {
      return 'video/webm';
    } else if (lowerFileName.endsWith('.m4v')) {
      return 'video/x-m4v';
    } else if (lowerFileName.endsWith('.3gp')) {
      return 'video/3gpp';
    }

    return 'image/jpeg'; // 기본값
  }

  /// 파일 이름에서 MIME 타입 추출
  static String? _getMimeTypeFromFileName(String? fileName) {
    if (fileName == null) return null;

    final lowerFileName = fileName.toLowerCase();
    if (lowerFileName.endsWith('.mov')) {
      return 'video/quicktime';
    } else if (lowerFileName.endsWith('.mp4')) {
      return 'video/mp4';
    } else if (lowerFileName.endsWith('.avi')) {
      return 'video/x-msvideo';
    } else if (lowerFileName.endsWith('.mkv')) {
      return 'video/x-matroska';
    } else if (lowerFileName.endsWith('.webm')) {
      return 'video/webm';
    } else if (lowerFileName.endsWith('.m4v')) {
      return 'video/x-m4v';
    } else if (lowerFileName.endsWith('.3gp')) {
      return 'video/3gpp';
    } else if (lowerFileName.endsWith('.pdf')) {
      return 'application/pdf';
    } else if (lowerFileName.endsWith('.doc') ||
        lowerFileName.endsWith('.docx')) {
      return 'application/msword';
    } else if (lowerFileName.endsWith('.xls') ||
        lowerFileName.endsWith('.xlsx')) {
      return 'application/vnd.ms-excel';
    }
    return null;
  }

  /// URL에서 파일 키 추출 (Presigned URL의 query parameter 제거)
  ///
  /// 예: https://bucket.s3.region.amazonaws.com/chatRoom/22/1/xxx.jpg?X-Amz-...
  /// -> chatRoom/22/1/xxx.jpg
  ///
  /// [url]은 Presigned URL입니다.
  static String extractFileKeyFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // path에서 첫 번째 '/' 제거
      final path = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
      return path;
    } catch (e) {
      // 파싱 실패 시 원본 URL 반환
      return url;
    }
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
    required String currentTime,
    types.Message? previousMessage,
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
