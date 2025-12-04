import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/chat/presentation/widget/widget.dart';

/// 채팅방 목록이 로드된 상태의 View
class ChatRoomListLoadedView extends StatelessWidget {
  /// ChatRoomListLoadedView 생성자
  ///
  /// [chatRoomList]는 표시할 채팅방 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [scrollController]는 스크롤 컨트롤러입니다.
  /// [isLoadingMore]는 더 불러오는 중인지 여부입니다.
  const ChatRoomListLoadedView({
    required this.chatRoomList,
    required this.pagination,
    required this.scrollController,
    required this.isLoadingMore,
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

  @override
  Widget build(BuildContext context) {
    // isLoadingMore이면 항상 마지막에 로딩 인디케이터 표시
    // 아니면 hasMore일 때만 표시
    final itemCount = isLoadingMore
        ? chatRoomList.length + 1
        : chatRoomList.length + ((pagination.hasMore ?? false) ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: 채팅방 목록 새로고침 로직 추가
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == chatRoomList.length) {
            // 마지막에 로딩 인디케이터 표시
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: isLoadingMore
                    ? const CircularProgressIndicator()
                    : const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
              ),
            );
          }
          final chatRoom = chatRoomList[index];
          return ChatRoomItemWidget(chatRoom: chatRoom);
        },
      ),
    );
  }
}
