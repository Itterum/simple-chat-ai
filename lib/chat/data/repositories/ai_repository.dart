import '../../domain/entities/ai_entity.dart';

abstract class AIRepository {
  Future<List<AIEntity>> getAI();
}