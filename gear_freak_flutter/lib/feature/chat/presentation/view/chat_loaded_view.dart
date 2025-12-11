import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/utils/format_utils.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/widget/widget.dart';

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
        widget.onLoadMore?.call();
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

  @override
  Widget build(BuildContext context) {
    // 상품 정보
    final productName = widget.product?.title ?? '상품 정보 없음';
    final price = widget.product != null
        ? '${formatPrice(widget.product!.price)}원'
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
        ChatProductInfoCardWidget(
          productName: productName,
          price: price,
          product: widget.product,
        ),

        // 채팅 메시지 목록
        Expanded(
          child: ChatMessageListWidget(
            messages: convertedMessages,
            currentUserId: widget.currentUser.id,
            scrollController: scrollController!,
            isLoadingMore: widget.isLoadingMore,
          ),
        ),

        // 메시지 입력창
        ChatMessageInputWidget(
          controller: _messageController,
          onSend: _sendMessage,
          onAddPressed: () {
            // TODO: 파일 첨부 기능
          },
        ),
      ],
    );
  }
}
