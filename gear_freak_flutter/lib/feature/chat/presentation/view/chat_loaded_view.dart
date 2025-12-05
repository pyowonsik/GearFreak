import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/presentation/widget/widget.dart';

/// 채팅 로드 완료 상태의 View
class ChatLoadedView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // 상품 정보 표시
    final productName = product?.title ?? '상품 정보 없음';
    final price = product != null
        ? '${product!.price.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )}원'
        : '가격 정보 없음';

    return Column(
      children: [
        // 상품 정보 카드
        ChatProductInfoCardWidget(
          productName: productName,
          price: price,
          product: product,
        ),
        // 채팅 UI
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // 위로 스크롤 시 이전 메시지 로드
              if (notification is ScrollUpdateNotification) {
                final metrics = notification.metrics;
                // 상단 300px 이내에 도달하면 이전 메시지 로드
                if (metrics.pixels <= 300 &&
                    !isLoadingMore &&
                    (pagination?.hasPreviousPage ?? false) &&
                    onLoadMore != null) {
                  onLoadMore!();
                }
              }
              return false;
            },
            child: Chat(
              messages: convertMessages(messages, participants, currentUserId),
              onSendPressed: onSendPressed,
              user: currentUser,
              showUserAvatars: true,
              showUserNames: true,
              theme: const DefaultChatTheme(
                backgroundColor: Color(0xFFF3F4F6),
                primaryColor: Color(0xFF2563EB),
                secondaryColor: Color(0xFFF3F4F6),
                inputBackgroundColor: Colors.white,
                inputTextColor: Color(0xFF1F2937),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
