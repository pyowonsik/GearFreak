import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/chat/data/datasource/chat_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/chat/data/repository/chat_repository_impl.dart';
import 'package:gear_freak_flutter/feature/chat/domain/repository/chat_repository.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/usecases.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_notifier.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';

/// Chat Remote DataSource Provider
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return const ChatRemoteDataSource();
});

/// Chat Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource);
});

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

/// Join Chat Room UseCase Provider
final joinChatRoomUseCaseProvider = Provider<JoinChatRoomUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return JoinChatRoomUseCase(repository);
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

/// Chat Notifier Provider
final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
