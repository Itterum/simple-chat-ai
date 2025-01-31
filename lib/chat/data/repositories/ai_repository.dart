import '../../domain/entities/ai_entity.dart';
import '../../domain/entities/message_entity.dart';

abstract class AIRepository {
  Future<List<AIEntity>> getAI();

  Future<MessageEntity> sendMessage(String model, String content);
}
