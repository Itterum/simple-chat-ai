import 'package:simple_chat_ai/chat/domain/entities/ai_entity.dart';
import '../../data/repositories/ai_repository.dart';

class GetAIUseCase {
  final AIRepository repository;

  GetAIUseCase(this.repository);

  Future<List<AIEntity>> execute() {
    return repository.getAI();
  }
}
