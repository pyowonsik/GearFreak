import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/s3/di/s3_providers.dart';
import 'package:gear_freak_flutter/feature/chat/data/datasource/chat_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/chat/data/repository/chat_repository_impl.dart';
import 'package:gear_freak_flutter/feature/chat/domain/repository/chat_repository.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/usecases.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_notifier.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_room_list_notifier.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_room_list_state.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';

/// Chat Remote DataSource Provider
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return const ChatRemoteDataSource();
});

/// Chat Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource);
});

/// 채팅방 읽음 처리 이벤트 Provider
/// 채팅방에서 읽음 처리가 완료되면 이 Provider에 chatRoomId를 설정하면
/// 채팅방 목록 Notifier가 자동으로 해당 채팅방의 unreadCount를 0으로 업데이트합니다.
final chatRoomReadProvider = StateProvider<int?>((ref) => null);

/// 새 메시지 이벤트 Provider
/// 메시지가 전송/수신되면 이 Provider에 ChatMessageResponseDto를 설정하면
/// 채팅방 목록 Notifier가 자동으로 해당 채팅방의 마지막 메시지와 시간을 업데이트합니다.
final newChatMessageProvider =
    StateProvider<pod.ChatMessageResponseDto?>((ref) => null);

/// Create Or Get Chat Room UseCase Provider
final createOrGetChatRoomUseCaseProvider =
    Provider<CreateOrGetChatRoomUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return CreateOrGetChatRoomUseCase(repository);
});

/// Get Chat Room By Id UseCase Provider
final getChatRoomByIdUseCaseProvider = Provider<GetChatRoomByIdUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetChatRoomByIdUseCase(repository);
});

/// Get User Chat Rooms By Product Id UseCase Provider
final getUserChatRoomsByProductIdUseCaseProvider =
    Provider<GetUserChatRoomsByProductIdUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetUserChatRoomsByProductIdUseCase(repository);
});

/// Get My Chat Rooms UseCase Provider
final getMyChatRoomsUseCaseProvider = Provider<GetMyChatRoomsUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetMyChatRoomsUseCase(repository);
});

/// Join Chat Room UseCase Provider
final joinChatRoomUseCaseProvider = Provider<JoinChatRoomUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return JoinChatRoomUseCase(repository);
});

/// Leave Chat Room UseCase Provider
final leaveChatRoomUseCaseProvider = Provider<LeaveChatRoomUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return LeaveChatRoomUseCase(repository);
});

/// Get Chat Participants UseCase Provider
final getChatParticipantsUseCaseProvider =
    Provider<GetChatParticipantsUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetChatParticipantsUseCase(repository);
});

/// Get Chat Messages UseCase Provider
final getChatMessagesUseCaseProvider = Provider<GetChatMessagesUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetChatMessagesUseCase(repository);
});

/// Send Message UseCase Provider
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return SendMessageUseCase(repository);
});

/// Subscribe Chat Message Stream UseCase Provider
final subscribeChatMessageStreamUseCaseProvider =
    Provider<SubscribeChatMessageStreamUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return SubscribeChatMessageStreamUseCase(repository);
});

/// Mark Chat Room As Read UseCase Provider
final markChatRoomAsReadUseCaseProvider =
    Provider<MarkChatRoomAsReadUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return MarkChatRoomAsReadUseCase(repository);
});

/// Update Chat Room Notification UseCase Provider
final updateChatRoomNotificationUseCaseProvider =
    Provider<UpdateChatRoomNotificationUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return UpdateChatRoomNotificationUseCase(repository);
});

/// Get Total Unread Chat Count UseCase Provider
final getTotalUnreadChatCountUseCaseProvider =
    Provider<GetTotalUnreadChatCountUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetTotalUnreadChatCountUseCase(repository);
});

/// 전체 읽지 않은 채팅 개수 Provider
/// BottomNavigationBar에서 사용하기 위한 FutureProvider
final totalUnreadChatCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final useCase = ref.watch(getTotalUnreadChatCountUseCaseProvider);
  final result = await useCase(null);
  return result.fold(
    (failure) {
      // 실패 시 0 반환
      debugPrint('❌ 읽지 않은 채팅 개수 조회 실패: ${failure.message}');
      return 0;
    },
    (count) => count,
  );
});

/// Chat Room List Notifier Provider (채팅방 목록 화면용 - 전체 채팅방)
final chatRoomListNotifierProvider =
    StateNotifierProvider.autoDispose<ChatRoomListNotifier, ChatRoomListState>(
  (ref) {
    final getMyChatRoomsUseCase = ref.watch(getMyChatRoomsUseCaseProvider);
    final getUserChatRoomsByProductIdUseCase =
        ref.watch(getUserChatRoomsByProductIdUseCaseProvider);
    final getChatParticipantsUseCase =
        ref.watch(getChatParticipantsUseCaseProvider);
    final getChatMessagesUseCase = ref.watch(getChatMessagesUseCaseProvider);
    final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
    final getChatRoomByIdUseCase = ref.watch(getChatRoomByIdUseCaseProvider);
    final leaveChatRoomUseCase = ref.watch(leaveChatRoomUseCaseProvider);
    final updateChatRoomNotificationUseCase =
        ref.watch(updateChatRoomNotificationUseCaseProvider);
    return ChatRoomListNotifier(
      ref,
      getMyChatRoomsUseCase,
      getUserChatRoomsByProductIdUseCase,
      getChatParticipantsUseCase,
      getChatMessagesUseCase,
      getProductDetailUseCase,
      getChatRoomByIdUseCase,
      leaveChatRoomUseCase,
      updateChatRoomNotificationUseCase,
    );
  },
);

/// Chat Room Selection Notifier Provider (채팅방 선택 화면용 - 특정 상품의 채팅방)
/// productId를 파라미터로 받아서 해당 상품의 채팅방만 조회
final chatRoomSelectionNotifierProvider = StateNotifierProvider.autoDispose
    .family<ChatRoomListNotifier, ChatRoomListState, int>(
  (ref, productId) {
    final getMyChatRoomsUseCase = ref.watch(getMyChatRoomsUseCaseProvider);
    final getUserChatRoomsByProductIdUseCase =
        ref.watch(getUserChatRoomsByProductIdUseCaseProvider);
    final getChatParticipantsUseCase =
        ref.watch(getChatParticipantsUseCaseProvider);
    final getChatMessagesUseCase = ref.watch(getChatMessagesUseCaseProvider);
    final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
    final getChatRoomByIdUseCase = ref.watch(getChatRoomByIdUseCaseProvider);
    final leaveChatRoomUseCase = ref.watch(leaveChatRoomUseCaseProvider);
    final updateChatRoomNotificationUseCase =
        ref.watch(updateChatRoomNotificationUseCaseProvider);
    return ChatRoomListNotifier(
      ref,
      getMyChatRoomsUseCase,
      getUserChatRoomsByProductIdUseCase,
      getChatParticipantsUseCase,
      getChatMessagesUseCase,
      getProductDetailUseCase,
      getChatRoomByIdUseCase,
      leaveChatRoomUseCase,
      updateChatRoomNotificationUseCase,
    );
  },
);

/// Chat Notifier Provider (채팅 화면용)
final chatNotifierProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((ref) {
  final createOrGetChatRoomUseCase =
      ref.watch(createOrGetChatRoomUseCaseProvider);
  final getChatRoomByIdUseCase = ref.watch(getChatRoomByIdUseCaseProvider);
  final getUserChatRoomsByProductIdUseCase =
      ref.watch(getUserChatRoomsByProductIdUseCaseProvider);
  final joinChatRoomUseCase = ref.watch(joinChatRoomUseCaseProvider);
  final getChatParticipantsUseCase =
      ref.watch(getChatParticipantsUseCaseProvider);
  final getChatMessagesUseCase = ref.watch(getChatMessagesUseCaseProvider);
  final sendMessageUseCase = ref.watch(sendMessageUseCaseProvider);
  final subscribeChatMessageStreamUseCase =
      ref.watch(subscribeChatMessageStreamUseCaseProvider);
  final uploadChatRoomImageUseCase =
      ref.watch(uploadChatRoomImageUseCaseProvider);
  final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
  final markChatRoomAsReadUseCase =
      ref.watch(markChatRoomAsReadUseCaseProvider);
  return ChatNotifier(
    ref,
    createOrGetChatRoomUseCase,
    getChatRoomByIdUseCase,
    getUserChatRoomsByProductIdUseCase,
    joinChatRoomUseCase,
    getChatParticipantsUseCase,
    getChatMessagesUseCase,
    sendMessageUseCase,
    subscribeChatMessageStreamUseCase,
    uploadChatRoomImageUseCase,
    getProductDetailUseCase,
    markChatRoomAsReadUseCase,
  );
});
