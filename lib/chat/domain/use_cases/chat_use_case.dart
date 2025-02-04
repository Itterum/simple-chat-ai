import '../../data/repositories/chat_repository.dart';
import '../entities/ai_entity.dart';
import '../entities/chat_entity.dart';

class InitialChatUseCase {
  final ChatRepository repository;

  InitialChatUseCase(this.repository);

  Future<ChatEntity> execute(AIEntity entity) async {
    return repository.createChat(entity);
  }
}

class GetChatsUseCase {
  final ChatRepository repository;

  GetChatsUseCase(this.repository);

  Future<List<ChatEntity>> execute() async {
    return repository.getChats();
  }
}
