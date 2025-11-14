import '../entity/chat_message.dart';
import '../repository/chat_repository.dart';

/// 채팅 목록 조회 UseCase
/// Domain Layer: 단일 책임 비즈니스 로직
class GetChatListUseCase {
  final ChatRepository repository;

  GetChatListUseCase(this.repository);

  /// 채팅 목록 조회
  Future<List<ChatMessage>> call() async {
    return await repository.getChatList();
  }
}

