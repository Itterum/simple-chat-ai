import '../../data/repositories/ai_repository.dart';
import '../entities/ai_entity.dart';

class GetAIUseCase {
  final AIRepository repository;

  GetAIUseCase(this.repository);

  Future<List<AIEntity>> execute() {
    return repository.getAI();
  }
}
