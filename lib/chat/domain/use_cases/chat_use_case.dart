import '../../../utils/generate_id.dart';
import '../entities/ai_entity.dart';
import '../entities/chat_entity.dart';

class InitialChatUseCase {
  ChatEntity execute(AIEntity entity) {
    return ChatEntity(
      id: generateShortId(),
      aiEntity: entity,
      messages: [],
    );
  }
}
