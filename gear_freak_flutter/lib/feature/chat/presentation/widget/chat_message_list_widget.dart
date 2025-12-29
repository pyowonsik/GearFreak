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

  /// 날짜가 바뀌었는지 확인
  bool _isDateChanged(DateTime? currentDate, DateTime? previousDate) {
    if (currentDate == null || previousDate == null) return false;
    final current =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    final previous =
        DateTime(previousDate.year, previousDate.month, previousDate.day);
    return current != previous;
  }

  /// 날짜 구분선 위젯 빌드
  Widget _buildDateSeparator(DateTime dateTime) {
    final dateText = ChatUtil.formatChatMessageDateSeparator(dateTime);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

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

            // 현재 메시지 날짜
            final currentDate = message.createdAt != null
                ? DateTime.fromMillisecondsSinceEpoch(message.createdAt!)
                : null;

            // 이전 메시지 정보 (reverse: true이므로 index - 1이 더 최신 메시지)
            final previousMessage = index > 0 ? messages[index - 1] : null;
            final previousDate = previousMessage?.createdAt != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    previousMessage!.createdAt!)
                : null;

            // 다음 메시지 정보 (reverse: true이므로 index + 1이 더 오래된 메시지)
            final nextMessage =
                index < messages.length - 1 ? messages[index + 1] : null;
            final nextDate = nextMessage?.createdAt != null
                ? DateTime.fromMillisecondsSinceEpoch(nextMessage!.createdAt!)
                : null;

            // 날짜가 바뀌었는지 확인 (날짜 구분선 표시)
            // 마지막 메시지(가장 오래된, index == messages.length - 1)이거나
            // 현재 메시지와 다음 메시지(더 오래된)의 날짜가 다른 경우 날짜 구분선 표시
            final showDateSeparator = index == messages.length - 1 ||
                _isDateChanged(currentDate, nextDate);

            // 시간 포맷팅 (시간만 표시)
            final currentTime = currentDate != null
                ? ChatUtil.formatChatMessageTime(currentDate)
                : '';

            // 이전 메시지 시간 (시간 표시 로직용)
            final previousTime = previousDate != null
                ? ChatUtil.formatChatMessageTime(previousDate)
                : null;

            // 카카오톡 방식: 같은 시간대의 메시지 그룹에서 가장 마지막(최신) 메시지에만 시간 표시
            final showTime = ChatUtil.shouldShowMessageTime(
              index: index,
              currentMessage: message,
              previousMessage: previousMessage,
              currentTime: currentTime,
              previousTime: previousTime,
            );

            // 날짜 구분선과 메시지를 함께 반환
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 날짜 구분선 (날짜가 바뀔 때만 표시)
                if (showDateSeparator && currentDate != null)
                  _buildDateSeparator(currentDate),

                // 메시지 위젯
                if (message is types.TextMessage)
                  ChatMessageBubbleWidget(
                    text: message.text,
                    isMine: isMine,
                    time: currentTime,
                    author: message.author,
                    showTime: showTime,
                  )
                else if (message is types.ImageMessage) ...[
                  // 이미지 또는 동영상 썸네일 표시
                  // ImageMessage로 변환된 경우 동영상일 수 있음 (chat_util에서 변환)
                  Builder(
                    builder: (context) {
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
                    },
                  ),
                ] else if (message is types.FileMessage)
                  Builder(
                    builder: (context) {
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
                    },
                  )
                else
                  const SizedBox.shrink(),
              ],
            );
          },
        ),
      ],
    );
  }
}
