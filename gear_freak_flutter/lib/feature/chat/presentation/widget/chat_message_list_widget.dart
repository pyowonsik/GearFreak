import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:gear_freak_flutter/feature/chat/presentation/utils/chat_util.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/widget/chat_message_bubble_widget.dart';

/// 채팅 메시지 목록 위젯
class ChatMessageListWidget extends StatelessWidget {
  /// ChatMessageListWidget 생성자
  ///
  /// [messages]는 표시할 메시지 목록입니다.
  /// [currentUserId]는 현재 사용자 ID입니다.
  /// [scrollController]는 스크롤 컨트롤러입니다.
  /// [isLoadingMore]는 추가 메시지 로딩 중 여부입니다.
  const ChatMessageListWidget({
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    this.isLoadingMore = false,
    super.key,
  });

  /// 메시지 목록
  final List<types.Message> messages;

  /// 현재 사용자 ID
  final String currentUserId;

  /// 스크롤 컨트롤러
  final ScrollController scrollController;

  /// 추가 메시지 로딩 중 여부
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          reverse: true, // 최신 메시지가 하단에
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMine = message.author.id == currentUserId;

            // 시간 포맷팅
            final currentTime = message.createdAt != null
                ? ChatUtil.formatChatMessageTime(
                    DateTime.fromMillisecondsSinceEpoch(
                      message.createdAt!,
                    ),
                  )
                : '';

            // 이전 메시지 정보 (더 최신 메시지)
            final previousMessage = index > 0 ? messages[index - 1] : null;
            final previousTime = previousMessage?.createdAt != null
                ? ChatUtil.formatChatMessageTime(
                    DateTime.fromMillisecondsSinceEpoch(
                      previousMessage!.createdAt!,
                    ),
                  )
                : null;

            // 카카오톡 방식: 같은 시간대의 메시지 그룹에서 가장 마지막(최신) 메시지에만 시간 표시
            final showTime = ChatUtil.shouldShowMessageTime(
              index: index,
              currentMessage: message,
              previousMessage: previousMessage,
              currentTime: currentTime,
              previousTime: previousTime,
            );

            if (message is types.TextMessage) {
              return ChatMessageBubbleWidget(
                text: message.text,
                isMine: isMine,
                time: currentTime,
                author: message.author,
                showTime: showTime,
              );
            } else if (message is types.ImageMessage) {
              // 이미지 또는 동영상 썸네일 표시
              // ImageMessage로 변환된 경우 동영상일 수 있음 (chat_util에서 변환)
              String? videoUrl;
              var displayName = message.name;
              var isVideo = false;

              // name에서 동영상 URL 추출 (형식: "VIDEO_URL:{URL}|{파일이름}")
              if (message.name.startsWith('VIDEO_URL:')) {
                final parts = message.name.substring(10).split('|');
                if (parts.length >= 2) {
                  videoUrl = parts[0];
                  displayName = parts[1];
                  isVideo = true;
                } else {
                  // 형식이 맞지 않으면 동영상 파일 확장자로 확인
                  isVideo = ChatUtil.isVideoFile(message.name);
                }
              } else {
                // 일반 이미지인 경우 파일 확장자로 확인
                isVideo = ChatUtil.isVideoFile(message.name);
              }

              return ChatMessageBubbleWidget(
                text: displayName,
                isMine: isMine,
                time: currentTime,
                author: message.author,
                showTime: showTime,
                imageUrl: message.uri, // 썸네일 URL
                isVideo: isVideo,
                videoUrl: videoUrl, // 실제 동영상 URL
              );
            } else if (message is types.FileMessage) {
              // 일반 파일 메시지
              final isVideo = ChatUtil.isVideoFile(message.name);

              // 동영상인 경우 썸네일이 없어도 표시 (나중에 썸네일 재생성 가능)
              if (isVideo) {
                return ChatMessageBubbleWidget(
                  text: message.name,
                  isMine: isMine,
                  time: currentTime,
                  author: message.author,
                  showTime: showTime,
                  isVideo: true,
                  videoUrl: message.uri, // 동영상 URL
                );
              }

              // 일반 파일은 텍스트로 표시
              return ChatMessageBubbleWidget(
                text: message.name,
                isMine: isMine,
                time: currentTime,
                author: message.author,
                showTime: showTime,
              );
            }

            return const SizedBox.shrink();
          },
        ),
        // 로딩 인디케이터
        if (isLoadingMore)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
