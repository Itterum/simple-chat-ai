import '../../data/repositories/ai_repository.dart';
import '../entities/ai_entity.dart';
import '../entities/message_entity.dart';

class AIUseCase {
  final AIRepository repository;

  AIUseCase(this.repository);

  Future<List<AIEntity>> getAI() {
    return repository.getAI();
  }

  Future<MessageEntity> sendMessage(AIEntity model, String content) {
    return repository.sendMessage(model, content);
  }
}
