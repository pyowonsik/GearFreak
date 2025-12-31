import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/presentation/presentation.dart';

/// 채팅방 목록이 로드된 상태의 View
class ChatRoomListLoadedView extends StatelessWidget {
  /// ChatRoomListLoadedView 생성자
  ///
  /// [chatRoomList]는 표시할 채팅방 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [scrollController]는 스크롤 컨트롤러입니다.
  /// [isLoadingMore]는 더 불러오는 중인지 여부입니다.
  /// [onRefresh]는 새로고침 콜백입니다.
  /// [participantsMap]는 채팅방별 참여자 정보입니다.
  /// [lastMessagesMap]는 채팅방별 마지막 메시지 정보입니다.
  /// [itemBuilder]는 채팅방 아이템을 빌드하는 콜백입니다. (선택)
  const ChatRoomListLoadedView({
    required this.chatRoomList,
    required this.pagination,
    required this.scrollController,
    required this.isLoadingMore,
    required this.onRefresh,
    this.participantsMap = const {},
    this.lastMessagesMap = const {},
    this.productImagesMap = const {},
    this.itemBuilder,
    super.key,
  });

  /// 채팅방 목록
  final List<pod.ChatRoom> chatRoomList;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 스크롤 컨트롤러
  final ScrollController scrollController;

  /// 더 불러오는 중인지 여부
  final bool isLoadingMore;

  /// 새로고침 콜백
  final Future<void> Function() onRefresh;

  /// 채팅방별 참여자 정보 (chatRoomId -> 참여자 목록)
  final Map<int, List<pod.ChatParticipantInfoDto>> participantsMap;

  /// 채팅방별 마지막 메시지 정보 (chatRoomId -> 마지막 메시지)
  final Map<int, pod.ChatMessageResponseDto> lastMessagesMap;

  /// 상품별 이미지 URL 정보 (productId -> imageUrl)
  final Map<int, String> productImagesMap;

  /// 채팅방 아이템 빌더 (선택)
  /// 제공되지 않으면 기본 `ChatRoomItemWidget`을 사용합니다.
  final Widget Function(BuildContext context, pod.ChatRoom chatRoom)?
      itemBuilder;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: chatRoomList.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRoomList[index];
          return itemBuilder != null
              ? itemBuilder!(context, chatRoom)
              : ChatRoomItemWidget(
                  chatRoom: chatRoom,
                  participants: chatRoom.id != null
                      ? participantsMap[chatRoom.id!]
                      : null,
                  lastMessage: chatRoom.id != null
                      ? lastMessagesMap[chatRoom.id!]
                      : null,
                  productImageUrl: productImagesMap[chatRoom.productId],
                );
        },
      ),
    );
  }
}
