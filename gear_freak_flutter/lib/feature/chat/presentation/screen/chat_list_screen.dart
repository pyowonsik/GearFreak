import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/view/view.dart';

/// 채팅 목록 화면
/// Presentation Layer: UI
class ChatListScreen extends ConsumerStatefulWidget {
  /// ChatListScreen 생성자
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: 채팅방 목록 조회 로직 추가 (getUserChatRoomsByProductId 사용)
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
      ),
      body: _buildBody(chatState),
    );
  }

  Widget _buildBody(ChatState state) {
    if (state.isLoading) {
      return const GbLoadingView();
    }

    if (state.error != null) {
      return GbErrorView(
        message: '에러: ${state.error}',
        onRetry: () {
          // TODO: 채팅방 목록 재조회 로직 추가
        },
      );
    }

    if (state.chatList.isEmpty) {
      return const GbEmptyView(
        message: '채팅 목록이 없습니다',
      );
    }

    return ChatListLoadedView(chatList: state.chatList);
  }
}
