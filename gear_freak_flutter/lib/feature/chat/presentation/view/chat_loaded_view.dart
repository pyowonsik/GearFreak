import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';

/// 채팅 로드 완료 상태 UI View
class ChatLoadedView extends ConsumerStatefulWidget {
  /// ChatLoadedView 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  /// [messages]는 메시지 목록입니다.
  /// [participants]는 참여자 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [product]는 상품 정보입니다.
  /// [currentUser]는 현재 사용자 정보입니다.
  /// [currentUserId]는 현재 사용자 ID입니다.
  /// [isLoadingMore]는 추가 메시지 로딩 중 여부입니다.
  /// [onLoadMore]는 이전 메시지 로드 콜백입니다.
  /// [onSendPressed]는 메시지 전송 콜백입니다.
  /// [convertMessages]는 메시지 변환 함수입니다.
  const ChatLoadedView({
    required this.chatRoom,
    required this.messages,
    required this.participants,
    required this.pagination,
    required this.currentUser,
    required this.currentUserId,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onSendPressed,
    required this.convertMessages,
    this.product,
    super.key,
  });

  /// 채팅방 정보
  final pod.ChatRoom chatRoom;

  /// 메시지 목록
  final List<pod.ChatMessageResponseDto> messages;

  /// 참여자 목록
  final List<pod.ChatParticipantInfoDto> participants;

  /// 페이지네이션 정보
  final pod.PaginatedChatMessagesResponseDto? pagination;

  /// 상품 정보
  final pod.Product? product;

  /// 현재 사용자 정보
  final types.User currentUser;

  /// 현재 사용자 ID
  final int? currentUserId;

  /// 추가 메시지 로딩 중 여부
  final bool isLoadingMore;

  /// 이전 메시지 로드 콜백
  final VoidCallback? onLoadMore;

  /// 메시지 전송 콜백
  final void Function(types.PartialText) onSendPressed;

  /// 메시지 변환 함수
  final List<types.Message> Function(
    List<pod.ChatMessageResponseDto>,
    List<pod.ChatParticipantInfoDto>,
    int?,
  ) convertMessages;

  @override
  ConsumerState<ChatLoadedView> createState() => _ChatLoadedViewState();
}

class _ChatLoadedViewState extends ConsumerState<ChatLoadedView>
    with PaginationScrollMixin {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // PaginationScrollMixin 초기화 (채팅용: reverse: true)
    initPaginationScroll(
      onLoadMore: () {
        if (widget.onLoadMore != null) {
          widget.onLoadMore!();
        }
      },
      getPagination: () => widget.pagination?.pagination,
      isLoading: () => widget.isLoadingMore,
      screenName: 'ChatLoadedView',
      reverse: true, // 채팅은 상단 스크롤 감지
    );
  }

  @override
  void dispose() {
    disposePaginationScroll();
    _messageController.dispose();
    super.dispose();
  }

  /// 메시지 전송
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    widget.onSendPressed(
      types.PartialText(text: _messageController.text.trim()),
    );

    _messageController.clear();
  }

  /// 시간 포맷팅
  String _formatTime(DateTime dateTime) {
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

  @override
  Widget build(BuildContext context) {
    // 상품 정보
    final productName = widget.product?.title ?? '상품 정보 없음';
    final price = widget.product != null
        ? '${widget.product!.price.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )}원'
        : '가격 정보 없음';

    // 메시지를 flutter_chat_types로 변환
    final convertedMessages = widget.convertMessages(
      widget.messages,
      widget.participants,
      widget.currentUserId,
    );

    return Column(
      children: [
        // 상품 정보 카드
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.product?.imageUrls?.isNotEmpty ?? false
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.product!.imageUrls!.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.shopping_bag,
                              size: 24,
                              color: Color(0xFF9CA3AF),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag,
                        size: 24,
                        color: Color(0xFF9CA3AF),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 채팅 메시지 목록
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                controller: scrollController,
                reverse: true, // 최신 메시지가 하단에
                padding: const EdgeInsets.all(16),
                itemCount: convertedMessages.length,
                itemBuilder: (context, index) {
                  final message = convertedMessages[index];
                  final isMine = message.author.id == widget.currentUser.id;

                  // 시간 포맷팅
                  final currentTime = message.createdAt != null
                      ? _formatTime(
                          DateTime.fromMillisecondsSinceEpoch(
                            message.createdAt!,
                          ),
                        )
                      : '';

                  // 카카오톡 방식: 같은 시간대의 메시지 그룹에서 가장 마지막(최신) 메시지에만 시간 표시
                  // reverse: true이므로 index 0이 최신 메시지(하단), index가 커질수록 오래된 메시지(상단)
                  // 이전 메시지(index - 1, 더 최신 메시지)와 시간이 다르면 현재 메시지에 시간 표시
                  var showTime = false;
                  if (index == 0) {
                    // 첫 번째 메시지(가장 최신)는 항상 시간 표시
                    showTime = true;
                  } else {
                    // 이전 메시지(더 최신 메시지)와 시간 비교
                    final previousMessage = convertedMessages[index - 1];
                    if (previousMessage.createdAt != null &&
                        message.createdAt != null) {
                      final previousTime = _formatTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          previousMessage.createdAt!,
                        ),
                      );
                      // 이전 메시지와 시간이 다르면 현재 메시지에 시간 표시
                      // (같은 시간대 그룹의 마지막 메시지)
                      if (currentTime != previousTime ||
                          previousMessage.author.id != message.author.id) {
                        showTime = true;
                      }
                    } else {
                      // 시간 정보가 없으면 표시
                      showTime = true;
                    }
                  }

                  if (message is types.TextMessage) {
                    return _buildMessageBubble(
                      message.text,
                      isMine,
                      currentTime,
                      message.author,
                      showTime: showTime,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              // 로딩 인디케이터
              if (widget.isLoadingMore)
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
          ),
        ),

        // 메시지 입력창
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF6B7280),
                  ),
                  onPressed: () {
                    // TODO: 파일 첨부 기능
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 메시지 버블 빌드
  Widget _buildMessageBubble(
    String text,
    bool isMine,
    String time,
    types.User author, {
    bool showTime = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            // 시간이 표시될 때만 아바타 표시 (같은 시간대면 아바타도 생략)
            if (showTime)
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF3F4F6),
                backgroundImage: author.imageUrl != null
                    ? NetworkImage(author.imageUrl!)
                    : null,
                child: author.imageUrl == null
                    ? Icon(
                        Icons.person,
                        color: Colors.grey.shade500,
                        size: 16,
                      )
                    : null,
              ),
            if (showTime) const SizedBox(width: 8),
            // 아바타가 없을 때 공간 확보
            if (!showTime) const SizedBox(width: 40),
          ],
          // 내 메시지는 시간이 왼쪽에 표시
          if (isMine && showTime) ...[
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color:
                    isMine ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isMine ? Colors.white : const Color(0xFF1F2937),
                  height: 1.4,
                ),
              ),
            ),
          ),
          // 상대방 메시지는 시간이 오른쪽에 표시
          if (!isMine && showTime) ...[
            const SizedBox(width: 8),
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
