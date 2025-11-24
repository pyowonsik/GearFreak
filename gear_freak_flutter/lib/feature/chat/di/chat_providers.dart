import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/chat/data/datasource/chat_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/chat/data/repository/chat_repository_impl.dart';
import 'package:gear_freak_flutter/feature/chat/domain/repository/chat_repository.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_list_usecase.dart';
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

/// Get Chat List UseCase Provider
final getChatListUseCaseProvider = Provider<GetChatListUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetChatListUseCase(repository); // const 생성자 사용 가능
});

/// Chat Notifier Provider
final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final getChatListUseCase = ref.watch(getChatListUseCaseProvider);
  return ChatNotifier(getChatListUseCase);
});
