import '../../data/repositories/ai_repository.dart';
import '../entities/ai_entity.dart';
import '../entities/message_entity.dart';

class GetAIUseCase {
  final AIRepository repository;

  GetAIUseCase(this.repository);

  Future<List<AIEntity>> execute() {
    return repository.getAI();
  }
}

class SendMessageToAIUseCase {
  final AIRepository repository;

  SendMessageToAIUseCase(this.repository);

  Future<MessageEntity> execute(String model, String content) {
    return repository.sendMessage(model, content);
  }
}