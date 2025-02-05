import '../../data/repositories/ai_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../entities/ai_entity.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

class ChatUseCase {
  final ChatRepository repository;
  final AIRepository aiRepository;

  ChatUseCase(this.repository, this.aiRepository);

  Future<ChatEntity> init(AIEntity entity) async {
    return repository.createChat(entity);
  }

  Future<List<ChatEntity>> getChats() async {
    return repository.getChats();
  }

  Future<MessageEntity> sendMessageToAI(AIEntity entity, String content) async {
    return aiRepository.sendMessage(entity, content);
  }

  Future<void> addMessage(String chatId, MessageEntity message) async {
    return repository.addMessage(chatId, message);
  }
}
