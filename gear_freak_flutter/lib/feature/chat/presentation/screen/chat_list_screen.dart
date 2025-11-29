import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/component/gb_empty_view.dart';
import 'package:gear_freak_flutter/common/component/gb_error_view.dart';
import 'package:gear_freak_flutter/common/component/gb_loading_view.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/widget/chat_item_widget.dart';

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
    // 화면 진입 시 채팅 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).loadChatList();
    });
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
          ref.read(chatNotifierProvider.notifier).loadChatList();
        },
      );
    }

    if (state.chatList.isEmpty) {
      return const GbEmptyView(
        message: '채팅 목록이 없습니다',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(chatNotifierProvider.notifier).loadChatList();
      },
      child: ListView.builder(
        itemCount: state.chatList.length,
        itemBuilder: (context, index) {
          final chat = state.chatList[index];
          return ChatItemWidget(chat: chat);
        },
      ),
    );
  }
}
