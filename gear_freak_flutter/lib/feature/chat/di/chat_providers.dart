import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasource/chat_remote_datasource.dart';
import '../data/repository/chat_repository_impl.dart';
import '../domain/repository/chat_repository.dart';
import '../domain/usecase/get_chat_list_usecase.dart';
import '../presentation/provider/chat_notifier.dart';

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
