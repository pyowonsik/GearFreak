import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 채팅 로드 완료 상태의 View
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

class _ChatLoadedViewState extends ConsumerState<ChatLoadedView> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 상품 정보 표시
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
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFE5E7EB),
                width: 1,
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
                child: widget.product?.imageUrls?.isNotEmpty == true
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
        // 채팅 UI
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // 위로 스크롤 시 이전 메시지 로드
              if (notification is ScrollUpdateNotification ||
                  notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                // flutter_chat_ui는 reverse: true로 동작하므로,
                // 위로 스크롤하면 pixels가 maxScrollExtent에 가까워짐
                // 상단 300px 이내에 도달하면 이전 메시지 로드
                final threshold = metrics.maxScrollExtent - 300;

                // 스크롤 위치가 임계값 이상이고, 스크롤 가능한 콘텐츠가 있을 때만 체크
                if (metrics.pixels >= threshold &&
                    metrics.maxScrollExtent > 0) {
                  // 디바운스: 이전 타이머 취소
                  _debounceTimer?.cancel();

                  // 300ms 후에 실행 (디바운스)
                  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    // 로딩 중이 아니고, 다음 페이지가 있고, 콜백이 있을 때만 실행
                    if (!widget.isLoadingMore &&
                        (widget.pagination?.hasNextPage ?? false) &&
                        widget.onLoadMore != null) {
                      widget.onLoadMore!();
                    }
                  });
                }
              }
              return false;
            },
            child: Stack(
              children: [
                Chat(
                  messages: convertedMessages,
                  onSendPressed: widget.onSendPressed,
                  user: widget.currentUser,
                  showUserAvatars: true,
                  showUserNames: false,
                  theme: DefaultChatTheme(
                    backgroundColor: Colors.white,
                    primaryColor: const Color(0xFF2563EB),
                    secondaryColor: const Color(0xFFF3F4F6),
                    inputBackgroundColor: const Color(0xFFF3F4F6),
                    inputBorderRadius: BorderRadius.circular(24),
                    inputTextColor: const Color(0xFF1F2937),
                    inputTextStyle: const TextStyle(fontSize: 14),
                    messageBorderRadius: 18,
                    receivedMessageBodyTextStyle: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    sentMessageBodyTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    dateDividerTextStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    emptyChatPlaceholderTextStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ),
                // 로딩 인디케이터
                if (widget.isLoadingMore)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white.withOpacity(0.8),
                      child: const Center(
                        child: CircularProgressIndicator(),
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
}
