import '../../domain/entities/ai_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../data_sources/remote_data_source.dart';
import 'ai_repository.dart';

class AIRepositoryImpl implements AIRepository {
  final RemoteDataSource remoteDataSource;

  AIRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AIEntity>> getAI() async {
    final aiModels = await remoteDataSource.fetchAI();

    return aiModels
        .map((model) => AIEntity(
              name: model.name,
              model: model.model,
              modifiedAt: model.modifiedAt,
              size: model.size,
              digest: model.digest,
              details: model.details,
            ))
        .toList();
  }

  @override
  Future<MessageEntity> sendMessage(String model, String content) async {
    final response = await remoteDataSource.sendMessageToAI(model, content);

    return MessageEntity(
      role: response.message.role,
      content: response.message.content,
      createdAt: DateTime.tryParse(response.createdAt),
    );
  }
}
