import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_room_list_state.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/view/view.dart';

/// 채팅방 목록 화면
/// Presentation Layer: UI
class ChatRoomListScreen extends ConsumerStatefulWidget {
  /// ChatRoomListScreen 생성자
  const ChatRoomListScreen({super.key});

  @override
  ConsumerState<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends ConsumerState<ChatRoomListScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: 채팅방 목록 조회 로직 추가 (getUserChatRoomsByProductId 사용)
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomListState = ref.watch(chatRoomListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
      ),
      body: _buildBody(chatRoomListState),
    );
  }

  Widget _buildBody(ChatRoomListState state) {
    return switch (state) {
      ChatRoomListInitial() || ChatRoomListLoading() => const GbLoadingView(),
      ChatRoomListError(:final message) => GbErrorView(
          message: '에러: $message',
          onRetry: () {
            // TODO: 채팅방 목록 재조회 로직 추가
          },
        ),
      ChatRoomListLoaded(:final chatRooms) => chatRooms.isEmpty
          ? const GbEmptyView(
              message: '채팅 목록이 없습니다',
            )
          : ChatRoomListLoadedView(chatRoomList: chatRooms),
    };
  }
}
