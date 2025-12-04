import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';

/// Chat Notifier
/// Presentation Layer: Riverpod 상태 관리
class ChatNotifier extends StateNotifier<ChatState> {
  /// ChatNotifier 생성자
  ChatNotifier() : super(const ChatState());

  // ==================== Public Methods (UseCase 호출) ====================

  // ==================== Public Methods (Service 호출) ====================

  // ==================== Private Helper Methods ====================
}
